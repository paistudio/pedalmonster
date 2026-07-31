import { supabase } from '../lib/supabase'
import { useAuth } from './useAuth'

const { state: authState } = useAuth()

const THUMB_MAX_DIMENSION = 800
const THUMB_QUALITY = 0.75

// Public URL for a file in the `media` bucket must be built via this REST path — Supabase's
// S3-compatible gateway path (`storage/v1/s3/...`) requires signed requests and 403s on a plain
// public bucket, per docs/19-supabase-only-backend-plan.md's confirmed gotcha.
function publicUrl(path) {
  return `${import.meta.env.VITE_SUPABASE_URL}/storage/v1/object/public/media/${path}`
}

// Every upload gets a compressed sibling in a `thumb/` subfolder next to the original — kept as
// a pure path convention (no DB column for it) so every existing `media_urls`/`avatar_url`
// string stays a single full-size URL, and any caller can derive the thumbnail from it with
// thumbUrl() below. Cards/feed rows/grids show the thumbnail; Post/Listing Detail's photo
// gallery and its fullscreen lightbox show the original.
function toThumbPath(path) {
  const idx = path.lastIndexOf('/')
  return `${path.slice(0, idx)}/thumb${path.slice(idx)}`
}

// Downscales + re-encodes as JPEG via a canvas — no extra dependency needed, every target
// browser supports createImageBitmap/canvas.toBlob. Not applied to non-image files (there
// aren't any today — every picker in the app is accept="image/*" — but this keeps the function
// safe if that ever changes).
async function compress(file) {
  if (!file.type.startsWith('image/')) return null
  const bitmap = await createImageBitmap(file)
  const scale = Math.min(1, THUMB_MAX_DIMENSION / Math.max(bitmap.width, bitmap.height))
  const width = Math.round(bitmap.width * scale)
  const height = Math.round(bitmap.height * scale)

  const canvas = document.createElement('canvas')
  canvas.width = width
  canvas.height = height
  canvas.getContext('2d').drawImage(bitmap, 0, 0, width, height)
  bitmap.close?.()

  return new Promise((resolve) => {
    canvas.toBlob((blob) => resolve(blob), 'image/jpeg', THUMB_QUALITY)
  })
}

async function uploadFile(file, folder = 'uploads') {
  const userId = authState.currentUser?.id ?? 'anonymous'
  const ext = file.name.includes('.') ? file.name.split('.').pop() : 'jpg'
  const path = `${folder}/${userId}/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`

  const uploadOriginal = supabase.storage
    .from('media')
    .upload(path, file, { cacheControl: '3600', contentType: file.type })

  // The thumbnail is a nice-to-have, not the source of truth — if compression or its upload
  // fails for any reason, thumbUrl() callers just fall back to loading the original (see
  // below), so a thumbnail failure must never fail the whole attach-a-photo action.
  const uploadThumb = compress(file)
    .then((blob) => {
      if (!blob) return
      return supabase.storage
        .from('media')
        .upload(toThumbPath(path), blob, { cacheControl: '3600', contentType: 'image/jpeg' })
    })
    .catch(() => {})

  const [{ error }] = await Promise.all([uploadOriginal, uploadThumb])
  if (error) throw error
  return publicUrl(path)
}

// Derives the compressed sibling's URL from a full-size media URL returned by uploadFile()
// above. Safe no-op on anything that isn't one of our own Storage URLs (a local blob: preview
// mid-upload, or any other string) — returns it unchanged rather than producing a broken path.
function thumbUrl(url) {
  if (!url || !url.includes('/storage/v1/object/public/media/')) return url
  const idx = url.lastIndexOf('/')
  return `${url.slice(0, idx)}/thumb${url.slice(idx)}`
}

export function useUpload() {
  return { uploadFile, thumbUrl }
}
