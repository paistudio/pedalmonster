<script setup>
import { ref } from 'vue'

const props = defineProps({
  onRefresh: { type: Function, required: true },
})
const emit = defineEmits(['scroll'])

const THRESHOLD = 64

const containerRef = ref(null)
const pullDistance = ref(0)
const refreshing = ref(false)
const isPulling = ref(false)

let startY = 0

function onTouchStart(e) {
  if (refreshing.value || containerRef.value.scrollTop > 0) return
  startY = e.touches[0].clientY
  isPulling.value = true
}

function onTouchMove(e) {
  if (!isPulling.value) return
  const delta = e.touches[0].clientY - startY
  if (delta <= 0) {
    pullDistance.value = 0
    return
  }
  e.preventDefault()
  pullDistance.value = Math.min(delta * 0.5, 90)
}

async function onTouchEnd() {
  if (!isPulling.value) return
  isPulling.value = false
  if (pullDistance.value >= THRESHOLD) {
    refreshing.value = true
    pullDistance.value = THRESHOLD
    await props.onRefresh()
    refreshing.value = false
  }
  pullDistance.value = 0
}
</script>

<template>
  <div
    ref="containerRef"
    class="ptr-container"
    @touchstart="onTouchStart"
    @touchmove="onTouchMove"
    @touchend="onTouchEnd"
    @scroll="emit('scroll', $event)"
  >
    <div class="ptr-indicator" :style="{ height: pullDistance + 'px' }">
      <span v-if="refreshing">Loading...</span>
      <span v-else-if="pullDistance > 0">
        {{ pullDistance >= THRESHOLD ? 'Release to refresh' : 'Pull to refresh' }}
      </span>
    </div>
    <div class="ptr-content" :class="{ 'ptr-content--dragging': isPulling }" :style="{ transform: `translateY(${pullDistance}px)` }">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.ptr-container {
  height: 100%;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

.ptr-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-size: 12px;
  color: var(--color-text-muted);
  transition: height 0.2s ease;
}

.ptr-content {
  transition: transform 0.2s ease;
}

.ptr-content--dragging {
  transition: none;
}
</style>
