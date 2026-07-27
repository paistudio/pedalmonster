<script setup>
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import PhotoGallery from '../components/PhotoGallery.vue'
import CommentsSheet from '../components/CommentsSheet.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useUserLocation } from '../composables/useUserLocation'
import { useCommentStore } from '../composables/useCommentStore'
import { currentUser } from '../mocks'
import { formatPrice } from '../utils/formatters'
import { distanceBetweenCities, formatDistance } from '../utils/geo'

const route = useRoute()
const router = useRouter()
const store = useFeedStore()
const { state: locationState } = useUserLocation()
const commentStore = useCommentStore()
const isCommentsSheetOpen = ref(false)

const post = computed(() => store.posts.find((p) => p.id === route.params.id && p.type === 'listing'))
const isOwnListing = computed(() => post.value?.user_id === currentUser.id)
const distanceLabel = computed(() => {
  if (!post.value?.location_city_id || !locationState.resolvedCityId) return ''
  return formatDistance(distanceBetweenCities(locationState.resolvedCityId, post.value.location_city_id))
})
const memberSince = computed(() =>
  post.value
    ? new Intl.DateTimeFormat('en-US', { month: 'long', year: 'numeric' }).format(
        new Date(post.value.author.created_at),
      )
    : '',
)

function openChat() {
  router.push(`/chat/${post.value.user_id}?product=${post.value.id}`)
}

function openSellerProfile() {
  router.push(`/profile/${post.value.user_id}`)
}

const commentCount = computed(() => (post.value ? commentStore.commentCountFor(post.value.id) : 0))
</script>

<template>
  <div v-if="post" class="detail">
    <header class="detail-header">
      <button class="back-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
    </header>

    <div class="detail-scroll">
      <PhotoGallery v-if="post.media_urls.length" :images="post.media_urls" thumbnails />

      <div class="detail-body">
        <h1 class="title">{{ post.title }}</h1>
        <p class="price">{{ formatPrice(post.type_data.price) }}</p>

        <div class="badges">
          <span class="badge">{{ post.type_data.category === 'bike' ? 'Bike' : 'Part' }}</span>
          <span class="badge">{{ post.type_data.condition === 'new' ? 'New' : 'Used' }}</span>
          <span v-if="post.type_data.status === 'sold'" class="badge badge--sold">Sold</span>
        </div>

        <p v-if="post.location" class="location">
          {{ post.location }}<span v-if="distanceLabel"> · {{ distanceLabel }}</span>
        </p>

        <p class="description">{{ post.description }}</p>

        <button class="seller" @click="openSellerProfile">
          <img class="avatar" :src="post.author.avatar_url" :alt="post.author.username" />
          <div class="seller-meta">
            <div class="seller-line">
              <span class="username">{{ post.author.username }}</span>
            </div>
            <span class="member-since">Member since {{ memberSince }}</span>
          </div>
        </button>

        <button class="comments-trigger" @click="isCommentsSheetOpen = true">
          <Icon icon="iconoir:chat-bubble" width="16" height="16" />
          {{ commentCount ? `${commentCount} Comments` : 'Comment' }}
        </button>
      </div>
    </div>

    <footer v-if="!isOwnListing" class="cta-bar">
      <button class="btn btn-primary" :disabled="post.type_data.status === 'sold'" @click="openChat">
        Chat Seller
      </button>
    </footer>
    <footer v-else-if="post.type_data.status !== 'sold'" class="cta-bar">
      <button class="btn btn-primary" @click="store.markSold(post)">Mark as Sold</button>
    </footer>

    <CommentsSheet
      :open="isCommentsSheetOpen"
      :post="post"
      @close="isCommentsSheetOpen = false"
    />
  </div>

  <div v-else class="not-found">
    <p>Listing not found.</p>
    <button class="btn btn-secondary" @click="router.push('/market')">Back to Market</button>
  </div>
</template>

<style scoped>
.detail {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.detail-header {
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.back-btn {
  border: none;
  background: none;
  color: var(--color-text);
  display: flex;
  padding: 4px;
}

.detail-scroll {
  flex: 1;
  overflow-y: auto;
}

.detail-body {
  padding: 16px;
}

.title {
  font-size: 18px;
  margin: 0 0 6px;
}

.price {
  font-size: 20px;
  font-weight: 400;
  color: var(--color-text);
  margin: 0 0 10px;
}

.badges {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 10px;
}

.badge {
  font-size: 11px;
  border: 1px solid var(--color-border);
  color: var(--color-brand);
  padding: 3px 10px;
  border-radius: 999px;
}

.badge--sold {
  color: var(--color-error);
  border-color: var(--color-error);
}

.location {
  font-size: 13px;
  color: var(--color-text-muted);
  margin: 0 0 12px;
}

.description {
  font-size: 14px;
  color: var(--color-text);
  white-space: pre-line;
  margin: 0 0 20px;
}

.seller {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 12px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: none;
  color: inherit;
  font: inherit;
  text-align: left;
}

.avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.seller-meta {
  display: flex;
  flex-direction: column;
  gap: 0;
  line-height: 1.8;
}

.seller-line {
  display: flex;
  align-items: center;
  gap: 6px;
  line-height: 1.8;
}

.username {
  font-size: 14px;
  font-weight: 400;
  line-height: 1.8;
}

.member-since {
  font-size: 12px;
  line-height: 1.8;
  color: var(--color-text-muted);
}

.comments-trigger {
  display: flex;
  align-items: center;
  gap: 6px;
  width: 100%;
  margin-top: 12px;
  padding: 12px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: none;
  color: var(--color-text-muted);
  font: inherit;
  font-size: 13px;
  text-align: left;
}

.cta-bar {
  flex-shrink: 0;
  display: flex;
  padding: 12px 16px calc(12px + env(safe-area-inset-bottom));
  border-top: 1px solid var(--color-border);
  background: var(--color-surface);
}

/* Grey-glass pill, same material as the bottom nav bar (see BottomNav.vue) —
   keeps primary listing CTAs visually consistent with the app's floating nav chrome. */
.cta-bar .btn-primary {
  background: rgba(54, 58, 63, 0.72);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.14);
  color: #ffffff;
}

.cta-bar .btn-primary:disabled {
  background: rgba(54, 58, 63, 0.35);
  border-color: var(--color-border);
  color: var(--color-text-muted);
}

.not-found {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  color: var(--color-text-muted);
}
</style>
