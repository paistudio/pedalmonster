<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import PostCard from '../components/PostCard.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useAppState } from '../composables/useAppState'

const router = useRouter()
const feedStore = useFeedStore()
const { state } = useAppState()

const likedPosts = computed(() =>
  feedStore.posts.filter((post) => state.likedPostIds.includes(post.id)),
)
</script>

<template>
  <div class="liked-screen">
    <header class="screen-header">
      <button class="icon-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <span class="screen-title">Liked</span>
      <div class="spacer" />
    </header>

    <div class="liked-body">
      <PostCard v-for="post in likedPosts" :key="post.id" :post="post" />
      <p v-if="!likedPosts.length" class="empty">
        Posts you like will show up here — tap the heart icon on any post.
      </p>
    </div>
  </div>
</template>

<style scoped>
.liked-screen {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.screen-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px;
}

.screen-title {
  font-size: 16px;
  color: var(--color-text);
}

.spacer {
  width: 40px;
  flex-shrink: 0;
}

.icon-btn {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 999px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  color: var(--color-text);
  transition: background-color 0.15s ease, transform 0.1s ease;
}

.icon-btn:active {
  background: rgba(255, 255, 255, 0.08);
  transform: scale(0.94);
}

.liked-body {
  flex: 1;
  overflow-y: auto;
  padding: 0 16px 16px;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 40px 16px;
}
</style>
