<script setup>
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import PhotoGallery from '../components/PhotoGallery.vue'
import CommentList from '../components/CommentList.vue'
import CommentComposer from '../components/CommentComposer.vue'
import BottomSheet from '../components/BottomSheet.vue'
import ReportPostSheet from '../components/ReportPostSheet.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useCommentStore } from '../composables/useCommentStore'
import { useAppState } from '../composables/useAppState'
import { useGroupStore } from '../composables/useGroupStore'
import { formatRelativeTime } from '../utils/formatters'

const DETAIL_TYPES = ['community_post', 'group_post']

const route = useRoute()
const router = useRouter()
const feedStore = useFeedStore()
const commentStore = useCommentStore()
const { isPostLiked, toggleLike } = useAppState()
const groupStore = useGroupStore()

const isMenuOpen = ref(false)
const isDeleteConfirmOpen = ref(false)
const isReportOpen = ref(false)

const post = computed(() => feedStore.posts.find((p) => p.id === route.params.id && DETAIL_TYPES.includes(p.type)))
const comments = computed(() => (post.value ? commentStore.getCommentsForPost(post.value.id) : []))
const isOwner = computed(() => (post.value ? feedStore.isPostOwner(post.value) : false))
const liked = computed(() => (post.value ? isPostLiked(post.value.id) : false))
const group = computed(() =>
  post.value?.type === 'group_post' ? groupStore.groups.find((g) => g.id === post.value.type_data.group_id) : null,
)

function submitComment({ body, media_urls }) {
  commentStore.addComment(post.value, body, media_urls)
}

function editPost() {
  isMenuOpen.value = false
  router.push(`/posts/${post.value.id}/edit`)
}

function requestDeletePost() {
  isMenuOpen.value = false
  isDeleteConfirmOpen.value = true
}

function confirmDeletePost() {
  feedStore.deletePost(post.value.id)
  isDeleteConfirmOpen.value = false
  router.replace('/')
}

function reportPost() {
  isMenuOpen.value = false
  isReportOpen.value = true
}
</script>

<template>
  <div v-if="post" class="detail">
    <header class="detail-header">
      <button class="back-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <div class="header-spacer" />
      <button class="header-icon-btn" aria-label="Post menu" @click="isMenuOpen = true">
        <Icon icon="iconoir:more-horiz" width="22" height="22" />
      </button>
    </header>

    <div class="detail-scroll">
      <div class="detail-body">
        <PhotoGallery v-if="post.media_urls.length" :images="post.media_urls" />

        <button v-if="group" class="group-link" @click="router.push(`/groups/${group.id}`)">
          <Icon icon="iconoir:group" width="13" height="13" />
          Posted in {{ group.name }}
        </button>

        <h1 v-if="post.title" class="post-title">{{ post.title }}</h1>
        <p class="description">{{ post.description }}</p>

        <div class="poster">
          <img class="avatar" :src="post.author.avatar_url" :alt="post.author.username" />
          <div class="poster-meta">
            <div class="poster-line">
              <span class="username">{{ post.author.username }}</span>
            </div>
            <span class="timestamp">Posted {{ formatRelativeTime(post.created_at) }}</span>
          </div>
        </div>

        <button
          class="like-row"
          :class="{ 'like-row--active': liked }"
          :aria-label="liked ? 'Unlike' : 'Like'"
          @click="toggleLike(post)"
        >
          <Icon :icon="liked ? 'iconoir:heart-solid' : 'iconoir:heart'" width="18" height="18" />
          {{ post.like_count }}
        </button>

        <h2 class="comments-heading">{{ comments.length }} Comments</h2>

        <CommentList :comments="comments" />
      </div>
    </div>

    <CommentComposer allow-attachments @submit="submitComment" />

    <BottomSheet :open="isMenuOpen" @close="isMenuOpen = false">
      <template v-if="isOwner">
        <button class="menu-item" @click="editPost">
          <Icon icon="iconoir:edit-pencil" width="18" height="18" />
          Edit post
        </button>
        <button class="menu-item menu-item--danger" @click="requestDeletePost">
          <Icon icon="iconoir:trash" width="18" height="18" />
          Delete post
        </button>
      </template>
      <button v-else class="menu-item" @click="reportPost">
        <Icon icon="iconoir:flag" width="18" height="18" />
        Report post
      </button>
    </BottomSheet>

    <BottomSheet :open="isDeleteConfirmOpen" @close="isDeleteConfirmOpen = false">
      <h2 class="sheet-title">Delete this post?</h2>
      <p class="sheet-body">
        This removes the post and every comment on it. This can't be undone.
      </p>
      <div class="sheet-actions">
        <button class="btn btn-secondary" @click="isDeleteConfirmOpen = false">Cancel</button>
        <button class="btn btn-danger" @click="confirmDeletePost">Delete post</button>
      </div>
    </BottomSheet>

    <ReportPostSheet :open="isReportOpen" :post-id="post.id" @close="isReportOpen = false" />
  </div>

  <div v-else class="not-found">
    <p>Post not found.</p>
    <button class="btn btn-secondary" @click="router.push('/')">Back to Home</button>
  </div>
</template>

<style scoped>
.detail {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.detail-header {
  display: flex;
  align-items: center;
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.back-btn {
  flex-shrink: 0;
  border: none;
  background: none;
  color: var(--color-text);
  display: flex;
  padding: 4px;
}

.header-spacer {
  flex: 1;
}

.header-icon-btn {
  flex-shrink: 0;
  border: none;
  background: none;
  color: var(--color-text);
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.detail-scroll {
  flex: 1;
  overflow-y: auto;
}

.detail-body {
  padding: 16px;
}

.group-link {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  border: none;
  background: none;
  color: var(--color-accent-alt);
  font-size: 12px;
  padding: 0;
  margin: 12px 0 8px;
}

.post-title {
  font-size: 17px;
  margin: 0 0 8px;
  color: var(--color-text);
}

.description {
  font-size: 15px;
  color: var(--color-text);
  white-space: pre-line;
  margin: 0 0 16px;
}

.poster {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  margin-bottom: 20px;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.poster-meta {
  display: flex;
  flex-direction: column;
  gap: 0;
  line-height: 1.8;
}

.poster-line {
  display: flex;
  align-items: center;
  gap: 6px;
  line-height: 1.8;
}

.username {
  font-size: 13px;
  line-height: 1.8;
  color: var(--color-text);
}

.timestamp {
  font-size: 11px;
  line-height: 1.8;
  color: var(--color-text-muted);
}

.like-row {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text-muted);
  padding: 6px 14px;
  border-radius: 999px;
  font-size: 13px;
  margin-bottom: 20px;
}

.like-row--active {
  color: var(--color-error);
  border-color: var(--color-error);
}

.comments-heading {
  font-size: 14px;
  margin: 0 0 12px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  border: none;
  background: none;
  color: var(--color-text);
  font: inherit;
  font-size: 14px;
  padding: 14px 4px;
  text-align: left;
}

.menu-item--danger {
  color: var(--color-error);
}

.sheet-title {
  font-size: 16px;
  margin: 4px 0 8px;
}

.sheet-body {
  font-size: 13px;
  color: var(--color-text-secondary);
  margin: 0 0 18px;
}

.sheet-actions {
  display: flex;
  gap: 10px;
  padding-bottom: 4px;
}

.btn-danger {
  background: var(--color-error);
  color: #ffffff;
  border-color: var(--color-error);
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
