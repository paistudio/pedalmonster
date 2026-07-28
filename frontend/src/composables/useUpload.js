import { supabase } from '../lib/supabase'
import { useAuth } from './useAuth'

const { state: authState } = useAuth()

// Public URL for a file in the `media` bucket must be built via this REST path — Supabase's
// S3-compatible gateway path (`storage/v1/s3/...`) requires signed requests and 403s on a plain
// public bucket, per docs/19-supabase-only-backend-plan.md's confirmed gotcha.
function publicUrl(path) {
  return `${import.meta.env.VITE_SUPABASE_URL}/storage/v1/object/public/media/${path}`
}

async function uploadFile(file, folder = 'uploads') {
  const userId = authState.currentUser?.id ?? 'anonymous'
  const ext = file.name.includes('.') ? file.name.split('.').pop() : 'jpg'
  const path = `${folder}/${userId}/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`
  const { error } = await supabase.storage.from('media').upload(path, file, {
    cacheControl: '3600',
    contentType: file.type,
  })
  if (error) throw error
  return publicUrl(path)
}

export function useUpload() {
  return { uploadFile }
}
