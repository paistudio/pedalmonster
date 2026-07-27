<script setup>
import { ref } from 'vue'
import { Icon } from '@iconify/vue'
import { useInstallPrompt } from '../composables/useInstallPrompt'

const { isInstallable, promptInstall } = useInstallPrompt()
const dismissed = ref(false)
</script>

<template>
  <div v-if="isInstallable && !dismissed" class="install-banner">
    <Icon icon="iconoir:download" width="18" height="18" />
    <span>Install Pedal Monster for quick access</span>
    <button class="install-btn" @click="promptInstall">Install</button>
    <button class="dismiss-btn" aria-label="Dismiss" @click="dismissed = true">
      <Icon icon="iconoir:xmark" width="16" height="16" />
    </button>
  </div>
</template>

<style scoped>
.install-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  color: var(--color-text);
  font-size: 13px;
}

.install-banner span {
  flex: 1;
}

.install-btn {
  border: 1px solid var(--color-primary);
  background: var(--color-primary);
  color: var(--color-on-primary);
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 400;
}

.dismiss-btn {
  border: none;
  background: transparent;
  color: var(--color-text-muted);
  display: flex;
  padding: 2px;
}
</style>
