<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import PostCard from '../components/PostCard.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useAppState } from '../composables/useAppState'

const route = useRoute()
const router = useRouter()
const feedStore = useFeedStore()
const { state } = useAppState()

const tagName = computed(() => route.params.tag || 'Topic')
const isFollowing = computed(() => state.followedTags.includes(tagName.value))
const relatedPosts = computed(() =>
  feedStore.posts.filter((post) =>
    (post.title || '').toLowerCase().includes(tagName.value.toLowerCase()) ||
    post.description.toLowerCase().includes(tagName.value.toLowerCase()),
  ),
)

function toggleFollow() {
  if (isFollowing.value) {
    state.followedTags = state.followedTags.filter((tag) => tag !== tagName.value)
  } else {
    state.followedTags = [...state.followedTags, tagName.value]
  }
}
</script>

<template>
  <div class="topic-detail">
    <header class="topic-header">
      <button class="icon-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <span class="topic-title">Topic: #{{ tagName }}</span>
      <button class="icon-btn" :aria-label="isFollowing ? 'Following' : 'Follow'" @click="toggleFollow">
        <Icon :icon="isFollowing ? 'iconoir:bookmark-solid' : 'iconoir:bookmark'" width="20" height="20" />
      </button>
    </header>

    <section class="topic-summary">
      <p>Discover the latest posts and conversations around this topic.</p>
      <div class="topic-stats">
        <span>{{ state.followedTags.includes(tagName) ? 'Following now' : 'Not followed yet' }}</span>
      </div>
    </section>

    <div class="topic-posts">
      <PostCard v-for="post in relatedPosts" :key="post.id" :post="post" />
      <p v-if="!relatedPosts.length" class="empty">No posts yet for this topic.</p>
    </div>
  </div>
</template>

<style scoped>
.topic-detail {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.topic-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px;
}

.topic-title {
  font-size: 16px;
  font-weight: 400;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
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

.topic-summary {
  padding: 16px;
  border-bottom: 1px solid var(--color-border);
}

.topic-stats {
  margin-top: 8px;
  color: var(--color-text-muted);
  font-size: 13px;
}

.topic-posts {
  flex: 1;
  overflow-y: auto;
  padding: 0 16px;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  padding: 32px 0;
}
</style>
