<script setup>
import { nextTick, reactive, ref } from 'vue'
import { Icon } from '@iconify/vue'
import { useUpload } from '../composables/useUpload'

const props = defineProps({
  images: { type: Array, required: true },
  thumbnails: { type: Boolean, default: false },
})

const { thumbUrl } = useUpload()
const scrollerRef = ref(null)
const fullscreenScrollerRef = ref(null)
const activeIndex = ref(0)
const isFullscreen = ref(false)

// Compressed thumbnails only exist for photos uploaded after this feature landed — older
// posts' originals have no `thumb/` sibling and would 404. Fall back to the full-size image
// for exactly the src(s) that fail, rather than assuming thumbnails always exist.
const thumbFailed = reactive(new Set())
function cardSrc(src) {
  return thumbFailed.has(src) ? src : thumbUrl(src)
}

function onScroll() {
  const el = scrollerRef.value
  if (!el) return
  activeIndex.value = Math.round(el.scrollLeft / el.clientWidth)
}

function onFullscreenScroll() {
  const el = fullscreenScrollerRef.value
  if (!el) return
  activeIndex.value = Math.round(el.scrollLeft / el.clientWidth)
}

async function openFullscreen(index = activeIndex.value) {
  activeIndex.value = index
  isFullscreen.value = true
  await nextTick()
  if (fullscreenScrollerRef.value) {
    fullscreenScrollerRef.value.scrollLeft = activeIndex.value * fullscreenScrollerRef.value.clientWidth
  }
}

function closeFullscreen() {
  isFullscreen.value = false
}
</script>

<template>
  <div class="gallery" @click.stop="openFullscreen">
    <div ref="scrollerRef" class="gallery-scroller" @scroll="onScroll">
      <img
        v-for="(src, i) in props.images"
        :key="i"
        :src="cardSrc(src)"
        class="gallery-image"
        loading="lazy"
        alt=""
        @error="thumbFailed.add(src)"
      />
    </div>
    <div v-if="props.images.length > 1" class="dots">
      <span
        v-for="(_, i) in props.images"
        :key="i"
        class="dot"
        :class="{ 'dot--active': i === activeIndex }"
      />
    </div>
  </div>

  <div v-if="props.thumbnails && props.images.length > 1" class="thumbnail-strip" @click.stop>
    <button
      v-for="(src, i) in props.images"
      :key="i"
      class="thumbnail"
      :class="{ 'thumbnail--active': i === activeIndex }"
      @click="openFullscreen(i)"
    >
      <img :src="cardSrc(src)" loading="lazy" alt="" @error="thumbFailed.add(src)" />
    </button>
  </div>

  <Teleport to="body">
    <div v-if="isFullscreen" class="fullscreen-overlay" @click="closeFullscreen">
      <button class="fullscreen-close" aria-label="Close" @click.stop="closeFullscreen">
        <Icon icon="iconoir:xmark" width="22" height="22" />
      </button>
      <div
        ref="fullscreenScrollerRef"
        class="fullscreen-scroller"
        @click.stop
        @scroll="onFullscreenScroll"
      >
        <img v-for="(src, i) in props.images" :key="i" :src="src" class="fullscreen-image" alt="" />
      </div>
      <div v-if="props.images.length > 1" class="dots dots--fullscreen">
        <span
          v-for="(_, i) in props.images"
          :key="i"
          class="dot"
          :class="{ 'dot--active': i === activeIndex }"
        />
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.gallery {
  position: relative;
  aspect-ratio: 4 / 3;
  background: var(--color-border);
}

.gallery-scroller {
  display: flex;
  height: 100%;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
}

.gallery-scroller::-webkit-scrollbar {
  display: none;
}

.gallery-image {
  flex: 0 0 100%;
  width: 100%;
  height: 100%;
  object-fit: cover;
  scroll-snap-align: start;
}

.dots {
  position: absolute;
  bottom: 8px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 4px;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.55);
}

.dot--active {
  background: #fff;
}

.fullscreen-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.95);
  z-index: 100;
  display: flex;
  align-items: center;
}

.fullscreen-close {
  position: absolute;
  top: calc(12px + env(safe-area-inset-top));
  right: 12px;
  z-index: 101;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background: rgba(25, 25, 25, 0.7);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
}

.fullscreen-scroller {
  display: flex;
  width: 100%;
  height: 100%;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  align-items: center;
}

.fullscreen-scroller::-webkit-scrollbar {
  display: none;
}

.fullscreen-image {
  flex: 0 0 100%;
  width: 100%;
  max-height: 100%;
  object-fit: contain;
  scroll-snap-align: start;
}

.dots--fullscreen {
  bottom: calc(20px + env(safe-area-inset-bottom));
}

.thumbnail-strip {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  scrollbar-width: none;
  padding: 10px 16px 0;
}

.thumbnail-strip::-webkit-scrollbar {
  display: none;
}

.thumbnail {
  flex: 0 0 auto;
  width: 56px;
  height: 56px;
  padding: 0;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  overflow: hidden;
  background: none;
}

.thumbnail--active {
  border-color: var(--color-text);
}

.thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}
</style>
