<script setup>
import { ref } from 'vue'
import { Icon } from '@iconify/vue'

const props = defineProps({
  modelValue: { type: Array, required: true },
  max: { type: Number, default: 5 },
})
const emit = defineEmits(['update:modelValue'])

const cameraInput = ref(null)
const galleryInput = ref(null)

function onFilesSelected(e) {
  const files = Array.from(e.target.files || [])
  const room = props.max - props.modelValue.length
  const urls = files.slice(0, room).map((file) => URL.createObjectURL(file))
  emit('update:modelValue', [...props.modelValue, ...urls])
  e.target.value = ''
}

function removePhoto(index) {
  URL.revokeObjectURL(props.modelValue[index])
  const next = [...props.modelValue]
  next.splice(index, 1)
  emit('update:modelValue', next)
}
</script>

<template>
  <div class="photo-picker">
    <div class="thumbs">
      <div v-for="(src, i) in modelValue" :key="src" class="thumb">
        <img :src="src" alt="" />
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
