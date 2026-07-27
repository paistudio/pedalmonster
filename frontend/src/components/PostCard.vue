<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import PhotoGallery from './PhotoGallery.vue'
import CommentsSheet from './CommentsSheet.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useAppState } from '../composables/useAppState'
import { useCommentStore } from '../composables/useCommentStore'
import { getGroupById } from '../mocks'
import { formatRelativeTime, formatPrice } from '../utils/formatters'

const props = defineProps({
  post: { type: Object, required: true },
  layout: { type: String, default: 'row' },
  hideGroupFooter: { type: Boolean, default: false },
})

const router = useRouter()
const store = useFeedStore()
const { isPostLiked, toggleLike } = useAppState()
const commentStore = useCommentStore()
const expanded = ref(false)
const isCommentsSheetOpen = ref(false)
const liked = computed(() => isPostLiked(props.post.id))
const commentCount = computed(() => commentStore.commentCountFor(props.post.id))

function openDetail() {
  if (props.post.type === 'listing') router.push(`/market/${props.post.id}`)
  // Community posts and group posts share the same Post Detail page — tapping
  // a group post's card opens the post itself, not the group it belongs to.
  else if (props.post.type === 'community_post' || props.post.type === 'group_post') {
    router.push(`/posts/${props.post.id}`)
  }
}

// The group-name row in the footer is a separate tap target from the card body,
// so it can route to Group Detail while the rest of the card opens Post Detail.
function openGroup() {
  router.push(`/groups/${props.post.type_data.group_id}`)
}

// Listings don't have a full Post Detail page (see ListingDetailView), so they
// get a lightweight comments sheet instead; community/group posts share the
// full comment thread already on their Post Detail page.
function openComments() {
  if (props.post.type === 'listing') isCommentsSheetOpen.value = true
  else router.push(`/posts/${props.post.id}`)
}

function openChat() {
  router.push(`/chat/${props.post.user_id}?product=${props.post.id}`)
}

function openTag(tag) {
  router.push({ name: 'topic-detail', params: { tag } })
}

const BADGES = {
  listing: { icon: 'iconoir:label', label: 'For Sale' },
  community_post: { icon: 'iconoir:chat-bubble', label: 'Community' },
  group_post: { icon: 'iconoir:group', label: 'Group' },
}

const badge = computed(() => BADGES[props.post.type])
const relativeTime = computed(() => formatRelativeTime(props.post.created_at))
const isLong = computed(() => props.post.description.length > 100)

const group = computed(() =>
  props.post.type === 'group_post' ? getGroupById(props.post.type_data.group_id) : null,
)
const isMember = computed(() =>
  group.value ? store.isGroupJoined(group.value.id) : false,
)
</script>

<template>
  <article v-if="layout === 'grid'" class="post-card post-card--grid" @click="openDetail">
    <div class="grid-media">
      <img
        v-if="post.media_urls.length"
        :src="post.media_urls[0]"
        class="grid-image"
        loading="lazy"
        alt=""
      />
      <span v-if="post.type_data?.status === 'sold'" class="grid-sold">Sold</span>
      <button
        class="like-btn like-btn--grid"
        :class="{ 'like-btn--active': liked }"
        :aria-label="liked ? 'Unlike' : 'Like'"
        @click.stop="toggleLike(post)"
      >
        <Icon :icon="liked ? 'iconoir:heart-solid' : 'iconoir:heart'" width="16" height="16" />
      </button>
    </div>
    <div class="grid-body">
      <p class="grid-title">{{ post.title }}</p>
      <p class="grid-price">{{ formatPrice(post.type_data.price) }}</p>
      <p v-if="post.location" class="grid-location">
        <Icon icon="iconoir:map-pin" width="11" height="11" />
        {{ post.location }}
      </p>
    </div>
  </article>

  <article v-else class="post-card" @click="openDetail">
    <header class="post-header">
      <img
        class="avatar"
        :src="post.author.avatar_url"
        :alt="post.author.username"
        @click.stop="router.push(`/profile/${post.author.id}`)"
      />
      <div class="author-meta">
        <div class="author-line">
          <span class="username" @click.stop="router.push(`/profile/${post.author.id}`)">{{ post.author.username }}</span>
        </div>
        <div class="meta-line">
          <span class="timestamp">{{ relativeTime }}</span>
          <span class="meta-dot">·</span>
          <span class="type-badge">
            <Icon :icon="badge.icon" width="11" height="11" />
            {{ badge.label }}
          </span>
        </div>
      </div>
      <div class="header-actions">
        <button
          class="like-btn"
          :class="{ 'like-btn--active': liked }"
          :aria-label="liked ? 'Unlike' : 'Like'"
          @click.stop="toggleLike(post)"
        >
          <Icon :icon="liked ? 'iconoir:heart-solid' : 'iconoir:heart'" width="18" height="18" />
        </button>
        <button class="comment-btn" aria-label="Comment" @click.stop="openComments">
          <Icon icon="iconoir:chat-bubble" width="17" height="17" />
          <span v-if="commentCount">{{ commentCount }}</span>
        </button>
      </div>
    </header>

    <div v-if="post.media_urls.length" class="gallery-bleed">
      <PhotoGallery :images="post.media_urls" />
    </div>

    <div class="post-body">
      <h3 v-if="post.title" class="post-title">{{ post.title }}</h3>
      <p class="post-description" :class="{ 'post-description--clamped': isLong && !expanded }">
        {{ post.description }}
        <button
          v-for="tag in post.tags"
          :key="tag"
          class="tag-inline"
          @click.stop="openTag(tag)"
        >
          #{{ tag }}
        </button>
      </p>
      <button v-if="isLong && !expanded" class="see-more" @click.stop="expanded = true">
        See more
      </button>
    </div>

    <footer v-if="post.type === 'listing' || (post.type === 'group_post' && !hideGroupFooter)" class="post-footer">
      <template v-if="post.type === 'listing'">
        <div class="footer-info">
          <span class="price">{{ formatPrice(post.type_data.price) }}</span>
          <span v-if="post.type_data.status === 'sold'" class="status-badge">Sold</span>
        </div>
        <button
          class="cta cta--primary"
          :disabled="post.type_data.status === 'sold'"
          @click.stop="openChat"
        >
          Chat Seller
        </button>
      </template>

      <template v-else-if="post.type === 'group_post'">
        <button class="footer-info footer-info--link" @click.stop="openGroup">
          <span>{{ group?.name }}</span>
        </button>
        <button
          class="cta"
          :class="{ 'cta--joined': isMember }"
          @click.stop="store.toggleGroupMembership(group.id)"
        >
          {{ isMember ? 'Joined' : 'Join Group' }}
        </button>
      </template>
    </footer>

    <CommentsSheet
      v-if="post.type === 'listing'"
      :open="isCommentsSheetOpen"
      :post="post"
      @close="isCommentsSheetOpen = false"
    />
  </article>
</template>

<style scoped>
.post-card {
  background: transparent;
  border: none;
  border-bottom: 1px solid var(--color-border);
  padding: 16px 0;
}

.post-card:last-child {
  border-bottom: none;
}

.post-header {
  display: flex;
  align-items: center;
  gap: 10px;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.header-actions {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 2px;
}

.like-btn {
  flex-shrink: 0;
  border: none;
  background: none;
  padding: 4px;
  color: var(--color-text-muted);
  display: flex;
  align-items: center;
  justify-content: center;
}

.like-btn--active {
  color: var(--color-error);
}

.comment-btn {
  flex-shrink: 0;
  border: none;
  background: none;
  padding: 4px 6px 4px 4px;
  color: var(--color-text-muted);
  display: flex;
  align-items: center;
  gap: 3px;
  font-size: 11px;
}

.gallery-bleed {
  width: calc(100% + var(--feed-pad-left, 16px) + var(--feed-pad-right, 16px));
  margin: 8px calc(-1 * var(--feed-pad-right, 16px)) 12px calc(-1 * var(--feed-pad-left, 16px));
}

.author-meta {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0;
  line-height: 1.8;
}

.author-line {
  display: flex;
  align-items: center;
  gap: 6px;
  min-width: 0;
  line-height: 1.8;
}

.username {
  flex-shrink: 1;
  min-width: 0;
  font-size: 13px;
  font-weight: 400;
  line-height: 1.8;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.meta-line {
  display: flex;
  align-items: center;
  gap: 4px;
  min-width: 0;
  line-height: 1.8;
}

.timestamp {
  font-size: 11px;
  line-height: 1.8;
  color: var(--color-text-muted);
  flex-shrink: 0;
}

.meta-dot {
  font-size: 11px;
  line-height: 1.8;
  color: var(--color-text-muted);
  flex-shrink: 0;
}

.type-badge {
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  gap: 3px;
  font-size: 11px;
  line-height: 1.8;
  color: var(--color-text-muted);
  white-space: nowrap;
}

.post-body {
  padding: 8px 0;
}

.tag-inline {
  display: inline;
  border: none;
  background: none;
  padding: 0;
  margin-inline-start: 5px;
  color: var(--color-accent-alt);
  font: inherit;
  font-size: inherit;
  line-height: inherit;
}

.post-title {
  font-size: 14px;
  margin: 0 0 4px;
  color: var(--color-text);
}

.post-description {
  font-size: 13px;
  color: var(--color-text-muted);
  margin: 0;
  white-space: pre-line;
}

.post-description--clamped {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.see-more {
  border: none;
  background: none;
  color: var(--color-accent);
  font-size: 12px;
  padding: 4px 0 0;
}

.post-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 10px 0 0;
}

.footer-info {
  display: flex;
  flex-direction: column;
  gap: 0;
  font-size: 12px;
  line-height: 1.8;
  color: var(--color-text-muted);
  min-width: 0;
}

.footer-info--link {
  border: none;
  background: none;
  padding: 0;
  text-align: left;
  font: inherit;
  color: var(--color-accent-alt);
}

.price {
  font-size: 14px;
  font-weight: 400;
  line-height: 1.8;
  color: var(--color-text);
}

.status-badge {
  font-size: 11px;
  line-height: 1.8;
  color: var(--color-error);
}

.cta {
  flex-shrink: 0;
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text);
  padding: 8px 14px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 400;
}

.cta:disabled {
  border-color: var(--color-border);
  color: var(--color-text-muted);
}

.cta--joined,
.cta--primary {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: var(--color-on-primary);
}

.cta--primary:disabled {
  background: var(--color-surface-input);
  border-color: var(--color-border);
  color: var(--color-text-muted);
}

.post-card--grid {
  border: 1px solid var(--color-border);
  border-bottom: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.grid-media {
  position: relative;
  aspect-ratio: 1 / 1;
  background: var(--color-border);
}

.grid-image {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.grid-sold {
  position: absolute;
  top: 8px;
  left: 8px;
  font-size: 11px;
  line-height: 1.8;
  color: #ffffff;
  background: rgba(10, 10, 10, 0.72);
  padding: 2px 8px;
  border-radius: 999px;
}

.like-btn--grid {
  position: absolute;
  top: 6px;
  right: 6px;
  background: rgba(10, 10, 10, 0.45);
  border-radius: 50%;
  color: #ffffff;
}

.grid-body {
  padding: 8px 10px 10px;
  line-height: 1.8;
}

.grid-title {
  font-size: 14px;
  font-weight: 400;
  line-height: 1.8;
  color: var(--color-text);
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.grid-price {
  font-size: 13px;
  font-weight: 400;
  line-height: 1.8;
  color: var(--color-text-secondary);
  margin: 0;
}

.grid-location {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  line-height: 1.8;
  color: var(--color-text-muted);
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.grid-location svg {
  flex-shrink: 0;
}
</style>
