<script setup>
defineProps({
  tabs: { type: Array, required: true },
  modelValue: { type: String, required: true },
})
const emit = defineEmits(['update:modelValue'])
</script>

<template>
  <div class="tab-bar">
    <button
      v-for="tab in tabs"
      :key="tab.value"
      class="tab"
      :class="{ 'tab--active': modelValue === tab.value }"
      @click="emit('update:modelValue', tab.value)"
    >
      {{ tab.label }}
    </button>
  </div>
</template>

<style scoped>
.tab-bar {
  display: flex;
  gap: 20px;
  overflow-x: auto;
  scrollbar-width: none;
  border-bottom: 1px solid var(--color-border);
}

.tab-bar::-webkit-scrollbar {
  display: none;
}

.tab {
  flex: 0 0 auto;
  position: relative;
  border: none;
  background: none;
  color: var(--color-text-muted);
  padding: 0 0 10px;
  font-size: 14px;
  font-weight: 400;
  white-space: nowrap;
}

.tab--active {
  color: var(--color-text);
}

.tab--active::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: -1px;
  height: 2px;
  background: var(--color-primary);
}
</style>
