<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'

const route = useRoute()
const router = useRouter()

const leftItems = [
  { to: '/', label: 'Home', icon: 'fa6-solid:house' },
  { to: '/market', label: 'Market', icon: 'fa6-solid:store' },
]
const rightItems = [
  { to: '/groups', label: 'Groups', icon: 'fa6-solid:users' },
  { to: '/profile', label: 'Profile', icon: 'fa6-solid:circle-user' },
]

const createChoices = [
  { label: 'Sell', icon: 'iconoir:label', route: '/create/listing' },
  { label: 'Post', icon: 'iconoir:chat-bubble', route: '/create/post' },
  { label: 'Group Post', icon: 'iconoir:group', route: '/create/group' },
]

const isCreateOpen = ref(false)
const navRef = ref(null)

function isActive(item) {
  return item.to === '/' ? route.path === '/' : route.path.startsWith(item.to)
}

function choose(choiceRoute) {
  isCreateOpen.value = false
  router.push(choiceRoute)
}

function onDocClick(e) {
  if (isCreateOpen.value && navRef.value && !navRef.value.contains(e.target)) {
    isCreateOpen.value = false
  }
}

onMounted(() => document.addEventListener('click', onDocClick))
onUnmounted(() => document.removeEventListener('click', onDocClick))
</script>

<template>
  <div ref="navRef" class="bottom-nav-wrap">
    <Transition name="menu-pop">
      <div v-if="isCreateOpen" class="create-menu">
        <button
          v-for="choice in createChoices"
          :key="choice.label"
          class="menu-item"
          @click="choose(choice.route)"
        >
          <Icon :icon="choice.icon" width="16" height="16" class="menu-icon" />
          <span>{{ choice.label }}</span>
        </button>
      </div>
    </Transition>

    <nav class="bottom-nav">
      <RouterLink
        v-for="item in leftItems"
        :key="item.to"
        :to="item.to"
        class="nav-item"
        :class="{ 'nav-item--active': isActive(item) }"
        :aria-label="item.label"
        @click="isCreateOpen = false"
      >
        <Icon :icon="item.icon" width="20" height="20" class="nav-icon" />
      </RouterLink>

      <button
        class="nav-item"
        :class="{ 'nav-item--active': isCreateOpen }"
        :aria-label="isCreateOpen ? 'Close' : 'Create post'"
        @click="isCreateOpen = !isCreateOpen"
      >
        <Icon
          icon="iconoir:plus"
          width="20"
          height="20"
          class="nav-icon nav-icon--plus"
          :class="{ 'nav-icon--rotated': isCreateOpen }"
        />
      </button>

      <RouterLink
        v-for="item in rightItems"
        :key="item.to"
        :to="item.to"
        class="nav-item"
        :class="{ 'nav-item--active': isActive(item) }"
        :aria-label="item.label"
        @click="isCreateOpen = false"
      >
        <Icon :icon="item.icon" width="20" height="20" class="nav-icon" />
      </RouterLink>
    </nav>
  </div>
</template>

<style scoped>
.bottom-nav-wrap {
  position: fixed;
  left: 16px;
  right: 16px;
  bottom: calc(12px + env(safe-area-inset-bottom));
  max-width: 448px;
  margin: 0 auto;
  z-index: 20;
}

.bottom-nav {
  display: flex;
  align-items: center;
  /* Grey glass. Keeps a darkness floor so white icons stay legible when the
     bar floats over blown-out photo content — a white tint washes out there. */
  background: rgba(54, 58, 63, 0.72);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.14);
  border-radius: 999px;
  padding: 6px;
}

.nav-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 10px 0;
  border: none;
  background: none;
  color: rgba(255, 255, 255, 0.5);
  text-decoration: none;
  border-radius: 999px;
  font-family: inherit;
}

.nav-item--active {
  color: #ffffff;
}

.nav-icon--plus {
  transition: transform 0.2s ease;
}

.nav-icon--rotated {
  transform: rotate(45deg);
}

.create-menu {
  position: absolute;
  bottom: calc(100% + 10px);
  left: 0;
  right: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
  /* Grey glass. Keeps a darkness floor so white icons stay legible when the
     bar floats over blown-out photo content — a white tint washes out there. */
  background: rgba(54, 58, 63, 0.72);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.14);
  border-radius: 16px;
  padding: 6px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 14px;
  border: none;
  background: none;
  color: #ffffff;
  font-family: inherit;
  font-size: 14px;
  border-radius: 10px;
  text-align: left;
}

.menu-item:active {
  background: rgba(255, 255, 255, 0.08);
}

.menu-icon {
  flex-shrink: 0;
}

.menu-pop-enter-active,
.menu-pop-leave-active {
  transition: opacity 0.16s ease, transform 0.16s ease;
  transform-origin: bottom center;
}

.menu-pop-enter-from,
.menu-pop-leave-to {
  opacity: 0;
  transform: scale(0.96) translateY(6px);
}
</style>
