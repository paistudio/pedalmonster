<script setup>
import { ref, computed } from 'vue'
import { Icon } from '@iconify/vue'
import { useCommentStore } from '../composables/useCommentStore'
import { formatRelativeTime } from '../utils/formatters'
import { avatarSrc } from '../utils/avatar'

const PREVIEW_COUNT = 5

const props = defineProps({
  comments: { type: Array, required: true },
})

const commentStore = useCommentStore()
const showAll = ref(false)
const visibleComments = computed(() =>
  showAll.value ? props.comments : props.comments.slice(0, PREVIEW_COUNT),
)

const editingId = ref(null)
const editDraft = ref('')
const pendingDeleteId = ref(null)

// Renders a comment body with @mentions highlighted, without introducing raw HTML injection.
function renderParts(body) {
  return body.split(/(@[a-zA-Z0-9._]+)/g).map((part, i) => ({
    key: i,
    text: part,
    mention: part.startsWith('@'),
  }))
}

function startEdit(comment) {
  editingId.value = comment.id
  editDraft.value = comment.description
}

function cancelEdit() {
  editingId.value = null
  editDraft.value = ''
}

function saveEdit(comment) {
  commentStore.editComment(comment, editDraft.value)
  editingId.value = null
  editDraft.value = ''
}

function requestDelete(commentId) {
  pendingDeleteId.value = commentId
}

function cancelDelete() {
  pendingDeleteId.value = null
}

function confirmDelete(comment) {
  commentStore.deleteComment(comment)
  pendingDeleteId.value = null
}
</script>

<template>
  <div class="comment-list">
    <div v-for="comment in visibleComments" :key="comment.id" class="comment-row">
      <img
        class="avatar avatar--sm"
        :src="avatarSrc(comment.author)"
        :alt="comment.author?.username"
      />
      <div class="comment-content">
        <div class="comment-header">
          <span class="username">{{ comment.author?.username }}</span>
          <span class="timestamp">{{ formatRelativeTime(comment.created_at) }}</span>
        </div>

        <template v-if="editingId === comment.id">
          <textarea v-model="editDraft" class="edit-textarea" />
          <div class="edit-actions">
            <button class="edit-cancel" @click="cancelEdit">Cancel</button>
            <button class="edit-save" @click="saveEdit(comment)">Save</button>
          </div>
        </template>

        <template v-else>
          <p class="comment-body">
            <template v-for="part in renderParts(comment.description)" :key="part.key">
              <span v-if="part.mention" class="mention">{{ part.text }}</span>
              <template v-else>{{ part.text }}</template>
            </template>
          </p>

          <div v-if="comment.media_urls?.length" class="comment-media">
            <img v-for="src in comment.media_urls" :key="src" :src="src" alt="" />
          </div>

          <div class="comment-actions">
            <button
              class="like"
              :class="{ 'like--active': commentStore.hasLiked(comment.id) }"
              @click="commentStore.toggleLike(comment)"
            >
              <Icon :icon="commentStore.hasLiked(comment.id) ? 'iconoir:heart-solid' : 'iconoir:heart'" width="14" height="14" />
              {{ comment.like_count }}
            </button>

            <template v-if="commentStore.isOwnComment(comment)">
              <div v-if="pendingDeleteId === comment.id" class="delete-confirm">
                <button class="delete-cancel" @click="cancelDelete">Cancel</button>
                <button class="delete-confirm-btn" @click="confirmDelete(comment)">Delete</button>
              </div>
              <template v-else>
                <button class="own-action" @click="startEdit(comment)">Edit</button>
                <button class="own-action own-action--danger" @click="requestDelete(comment.id)">Delete</button>
              </template>
            </template>
          </div>
        </template>
      </div>
    </div>

    <p v-if="!comments.length" class="empty">No comments yet — be the first to reply.</p>

    <button
      v-if="!showAll && comments.length > PREVIEW_COUNT"
      class="show-more"
      @click="showAll = true"
    >
      Show {{ comments.length - PREVIEW_COUNT }} more comments
    </button>
  </div>
</template>

<style scoped>
.comment-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.comment-row {
  display: flex;
  gap: 10px;
}

.avatar--sm {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.comment-content {
  flex: 1;
  min-width: 0;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
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
  margin-left: auto;
}

.comment-body {
  font-size: 14px;
  color: var(--color-text);
  margin: 0 0 6px;
  white-space: pre-line;
}

.mention {
  color: var(--color-accent-alt);
}

.comment-media {
  display: flex;
  gap: 6px;
  margin: 0 0 6px;
}

.comment-media img {
  width: 64px;
  height: 64px;
  border-radius: 8px;
  object-fit: cover;
}

.comment-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.like {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text-muted);
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
}

.like--active {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: var(--color-on-primary);
}

.own-action {
  border: none;
  background: none;
  color: var(--color-text-muted);
  font-size: 12px;
  padding: 4px 0;
}

.own-action--danger {
  color: var(--color-error);
}

.delete-confirm {
  display: flex;
  gap: 8px;
}

.delete-cancel {
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text);
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
}

.delete-confirm-btn {
  border: 1px solid var(--color-error);
  background: var(--color-error);
  color: #ffffff;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
}

.edit-textarea {
  width: 100%;
  min-height: 60px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 8px 10px;
  font: inherit;
  font-size: 14px;
  background: var(--color-surface-input);
  color: var(--color-text);
  margin-bottom: 6px;
  resize: vertical;
}

.edit-actions {
  display: flex;
  gap: 8px;
  margin-bottom: 4px;
}

.edit-cancel {
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text);
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
}

.edit-save {
  border: 1px solid var(--color-primary);
  background: var(--color-primary);
  color: var(--color-on-primary);
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 16px 0;
}

.show-more {
  align-self: center;
  border: none;
  background: none;
  color: var(--color-accent);
  font-size: 13px;
  padding: 4px 0;
}
</style>
