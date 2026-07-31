<script setup>
import { ref } from 'vue'
import { Icon } from '@iconify/vue'
import { useUpload } from '../../composables/useUpload'

const props = defineProps({
  modelValue: { type: Array, required: true },
  max: { type: Number, default: 5 },
  // Storage path prefix (docs/19-supabase-only-backend-plan.md's `media` bucket) — keeps
  // uploads from different features browsable/cleanable separately in the bucket.
  folder: { type: String, default: 'uploads' },
  // The `media` bucket's storage.objects insert policy requires `auth.role() = 'authenticated'`
  // (20260728000006_storage_media_bucket_policies.sql) — a picker used before the caller has a
  // session (RegisterView's avatar field, picked before signUp() runs) would have every upload
  // silently 403 and get dropped by the .catch() below. Set this false to only ever hold local
  // blob previews + the raw File objects; the parent calls uploadPending() once a session
  // actually exists.
  autoUpload: { type: Boolean, default: true },
})
const emit = defineEmits(['update:modelValue', 'update:uploading'])

const { uploadFile, thumbUrl } = useUpload()
const cameraInput = ref(null)
const galleryInput = ref(null)
const pendingCount = ref(0)
const filesByBlobUrl = new Map()

function setPending(delta) {
  pendingCount.value += delta
  emit('update:uploading', pendingCount.value > 0)
}

function upload(file, blobUrl) {
  setPending(1)
  return uploadFile(file, props.folder)
    .then((realUrl) => {
      const idx = props.modelValue.indexOf(blobUrl)
      if (idx !== -1) {
        const next = [...props.modelValue]
        next[idx] = realUrl
        emit('update:modelValue', next)
      }
      filesByBlobUrl.delete(blobUrl)
    })
    .catch(() => {
      const idx = props.modelValue.indexOf(blobUrl)
      if (idx !== -1) {
        const next = [...props.modelValue]
        next.splice(idx, 1)
        emit('update:modelValue', next)
      }
      filesByBlobUrl.delete(blobUrl)
    })
    .finally(() => {
      URL.revokeObjectURL(blobUrl)
      setPending(-1)
    })
}

function onFilesSelected(e) {
  const files = Array.from(e.target.files || [])
  const room = props.max - props.modelValue.length
  const selected = files.slice(0, room)
  const blobUrls = selected.map((file) => URL.createObjectURL(file))
  // Show local previews immediately; each blob URL is swapped for its real Supabase Storage
  // URL (or dropped, on failure) once that file's upload resolves — the array can be edited
  // (photos removed) while uploads are still in flight, so we look items up by identity
  // (indexOf) rather than trusting a captured index.
  emit('update:modelValue', [...props.modelValue, ...blobUrls])
  e.target.value = ''

  selected.forEach((file, i) => {
    const blobUrl = blobUrls[i]
    if (props.autoUpload) {
      upload(file, blobUrl)
    } else {
      filesByBlobUrl.set(blobUrl, file)
    }
  })
}

function removePhoto(index) {
  const url = props.modelValue[index]
  if (url.startsWith('blob:')) {
    URL.revokeObjectURL(url)
    filesByBlobUrl.delete(url)
  }
  const next = [...props.modelValue]
  next.splice(index, 1)
  emit('update:modelValue', next)
}

// For autoUpload=false pickers: uploads every still-pending file now (called once the caller
// has a real session, e.g. right after RegisterView's signUp() resolves). Resolves once every
// upload has settled, so modelValue holds only real URLs (or has dropped any that failed).
async function uploadPending() {
  await Promise.all([...filesByBlobUrl.entries()].map(([blobUrl, file]) => upload(file, blobUrl)))
}

defineExpose({ uploadPending })
</script>

<template>
  <div class="photo-picker">
    <div class="thumbs">
      <div v-for="(src, i) in modelValue" :key="src" class="thumb">
        <img :src="thumbUrl(src)" alt="" />
        <button class="remove-btn" aria-label="Remove photo" @click="removePhoto(i)">
          <Icon icon="iconoir:xmark" width="12" height="12" />
        </button>
      </div>
      <div v-if="modelValue.length < max" class="add-tile" @click="cameraInput.click()">
        <Icon icon="iconoir:camera" width="20" height="20" />
        <span>Take Photo</span>
      </div>
    </div>
    <button
      v-if="modelValue.length < max"
      type="button"
      class="gallery-btn"
      @click="galleryInput.click()"
    >
      <Icon icon="iconoir:media-image" width="16" height="16" />
      Choose from Gallery
    </button>

    <input
      ref="cameraInput"
      type="file"
      accept="image/*"
      capture="environment"
      class="hidden-input"
      @change="onFilesSelected"
    />
    <input
      ref="galleryInput"
      type="file"
      accept="image/*"
      multiple
      class="hidden-input"
      @change="onFilesSelected"
    />
  </div>
</template>

<style scoped>
.photo-picker {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.thumbs {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.thumb {
  position: relative;
  width: 72px;
  height: 72px;
  border-radius: 8px;
  overflow: hidden;
}

.thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.remove-btn {
  position: absolute;
  top: 2px;
  right: 2px;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.6);
  color: #fff;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

.add-tile {
  width: 72px;
  height: 72px;
  border: 1px dashed var(--color-border);
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2px;
  color: var(--color-text-muted);
  font-size: 10px;
  text-align: center;
}

.gallery-btn {
  align-self: flex-start;
  display: flex;
  align-items: center;
  gap: 6px;
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text);
  padding: 8px 14px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 400;
}

.hidden-input {
  display: none;
}
</style>
