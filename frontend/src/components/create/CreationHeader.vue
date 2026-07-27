<script setup>
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'

defineProps({
  title: { type: String, required: true },
  step: { type: Number, default: null },
  totalSteps: { type: Number, default: null },
})

const router = useRouter()
</script>

<template>
  <header class="creation-header">
    <button class="close-btn" aria-label="Cancel" @click="router.push('/')">
      <Icon icon="iconoir:xmark" width="20" height="20" />
    </button>
    <div class="header-text">
      <h1>{{ title }}</h1>
      <span v-if="totalSteps > 1" class="step-label">Step {{ step }} of {{ totalSteps }}</span>
    </div>
    <div class="spacer" />
  </header>
  <div v-if="totalSteps > 1" class="progress-dots">
    <span
      v-for="n in totalSteps"
      :key="n"
      class="dot"
      :class="{ 'dot--active': n <= step }"
    />
  </div>
</template>

<style scoped>
.creation-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 12px;
  border-bottom: 1px solid var(--color-border);
}

.close-btn {
  border: none;
  background: none;
  color: var(--color-text);
  display: flex;
  padding: 4px;
  flex-shrink: 0;
}

.header-text {
  flex: 1;
  text-align: center;
}

.header-text h1 {
  font-size: 15px;
  margin: 0;
  color: var(--color-text);
}

.step-label {
  font-size: 11px;
  color: var(--color-text-muted);
}

.spacer {
  width: 28px;
  flex-shrink: 0;
}

.progress-dots {
  display: flex;
  gap: 4px;
  padding: 8px 16px 0;
}

.dot {
  flex: 1;
  height: 3px;
  border-radius: 2px;
  background: var(--color-border);
}

.dot--active {
  background: var(--color-accent);
}
</style>
