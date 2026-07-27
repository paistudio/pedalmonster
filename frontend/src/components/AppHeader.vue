<script setup>
import { computed } from 'vue'
import { Icon } from '@iconify/vue'
import logoText from '../assets/pedalmonster_logo_text.svg'

const props = defineProps({
  hasUnread: { type: Boolean, default: false },
  drawerOpen: { type: Boolean, default: false },
})

const emit = defineEmits(['toggle-menu', 'open-inbox'])

const dotClass = computed(() => ({ 'app-header__badge': true, 'app-header__badge--visible': props.hasUnread }))
</script>

<template>
  <header class="app-header">
    <button class="app-header__icon" aria-label="Open menu" @click="emit('toggle-menu')">
      <Icon :icon="drawerOpen ? 'iconoir:xmark' : 'iconoir:menu'" width="20" height="20" />
    </button>

    <div class="app-header__center">
      <slot name="center">
        <RouterLink to="/" class="app-header__logo" aria-label="Pedal Monster">
          <img :src="logoText" alt="Pedal Monster" class="app-header__logo-img" />
        </RouterLink>
      </slot>
    </div>

    <div class="app-header__right">
      <slot name="right">
        <button class="app-header__icon app-header__icon--right" aria-label="Inbox" @click="emit('open-inbox')">
          <Icon icon="iconoir:bell" width="20" height="20" />
          <span :class="dotClass" />
        </button>
      </slot>
    </div>
  </header>
</template>

<style scoped>
.app-header {
  position: fixed;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: min(100%, 480px);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px calc(12px + env(safe-area-inset-top));
  background: linear-gradient(to bottom, rgba(10, 10, 10, 0.88) 0%, rgba(10, 10, 10, 0) 100%);
  z-index: 30;
}

.app-header__icon {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 999px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  color: var(--color-text);
  transition: background-color 0.15s ease, border-color 0.15s ease, transform 0.1s ease;
}

.app-header__icon:active {
  background: rgba(255, 255, 255, 0.08);
  transform: scale(0.94);
}

.app-header__icon--right {
  position: relative;
}

.app-header__center {
  flex: 1;
  min-width: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.app-header__right {
  flex-shrink: 0;
  display: flex;
  align-items: center;
}

.app-header__logo {
  display: flex;
  align-items: center;
  text-decoration: none;
}

.app-header__logo-img {
  height: 45px;
  width: auto;
}

.app-header__title {
  color: var(--color-text);
  font-size: 16px;
  font-weight: 400;
}

.app-header__badge {
  position: absolute;
  top: 5px;
  right: 5px;
  width: 10px;
  height: 10px;
  border-radius: 999px;
  background: var(--color-error);
  border: 2px solid var(--color-bg);
  opacity: 0;
  transform: scale(0.7);
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.app-header__badge--visible {
  opacity: 1;
  transform: scale(1);
}
</style>
