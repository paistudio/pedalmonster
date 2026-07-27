<script setup>
import { ref, computed, nextTick } from 'vue'
import { Icon } from '@iconify/vue'
import PhotoPicker from './create/PhotoPicker.vue'
import { users, currentUser } from '../mocks'

const props = defineProps({
  placeholder: { type: String, default: 'Write a comment...' },
  allowAttachments: { type: Boolean, default: false },
})
const emit = defineEmits(['submit'])

const draft = ref('')
const photos = ref([])
const showPhotoPicker = ref(false)
const inputEl = ref(null)
// null = no active "@" trigger; otherwise the partial username typed after the "@"
const mentionQuery = ref(null)

const mentionMatches = computed(() => {
  if (mentionQuery.value === null) return []
  const q = mentionQuery.value.toLowerCase()
  return users
    .filter((u) => u.id !== currentUser.id && u.username.toLowerCase().includes(q))
    .slice(0, 5)
})

// Looks backward from the caret for an unfinished "@handle" so the dropdown
// only appears while actively typing a mention, not for any "@" in the text.
function detectMention() {
  const el = inputEl.value
  if (!el) return
  const pos = el.selectionStart ?? draft.value.length
  const uptoCursor = draft.value.slice(0, pos)
  const match = uptoCursor.match(/(?:^|\s)@([a-zA-Z0-9._]*)$/)
  mentionQuery.value = match ? match[1] : null
}

function selectMention(user) {
  const el = inputEl.value
  const pos = el?.selectionStart ?? draft.value.length
  const uptoCursor = draft.value.slice(0, pos)
  const rest = draft.value.slice(pos)
  const replaced = uptoCursor.replace(/@([a-zA-Z0-9._]*)$/, `@${user.username} `)
  draft.value = replaced + rest
  mentionQuery.value = null
  nextTick(() => {
    el?.focus()
    el?.setSelectionRange(replaced.length, replaced.length)
  })
}

function submit() {
  const text = draft.value.trim()
  if (!text && !photos.value.length) return
  emit('submit', { body: text, media_urls: photos.value })
  draft.value = ''
  photos.value = []
  showPhotoPicker.value = false
  mentionQuery.value = null
}
</script>

<template>
  <div class="comment-composer">
    <div v-if="mentionMatches.length" class="mention-dropdown">
      <button
        v-for="user in mentionMatches"
        :key="user.id"
        class="mention-option"
        @mousedown.prevent="selectMention(user)"
      >
        <img class="mention-avatar" :src="user.avatar_url" :alt="user.username" />
        <span class="mention-username">{{ user.username }}</span>
      </button>
    </div>

    <div v-if="allowAttachments && showPhotoPicker" class="attach-panel">
      <PhotoPicker v-model="photos" :max="4" />
    </div>
    <div v-else-if="photos.length" class="attach-preview">
      <img v-for="src in photos" :key="src" :src="src" alt="" />
    </div>

    <footer class="composer">
      <button
        v-if="allowAttachments"
        class="attach-btn"
        aria-label="Attach photos"
        @click="showPhotoPicker = !showPhotoPicker"
      >
        <Icon icon="iconoir:media-image" width="18" height="18" />
      </button>
      <input
        ref="inputEl"
        v-model="draft"
        class="composer-input"
        :placeholder="placeholder"
        @input="detectMention"
        @click="detectMention"
        @keyup.enter="submit"
      />
      <button class="send-btn" aria-label="Send comment" @click="submit">
        <Icon icon="iconoir:send" width="18" height="18" />
      </button>
    </footer>
  </div>
</template>

<style scoped>
.comment-composer {
  position: relative;
  flex-shrink: 0;
}

.mention-dropdown {
  position: absolute;
  left: 12px;
  right: 12px;
  bottom: 100%;
  margin-bottom: 4px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
}

.mention-option {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  border: none;
  background: none;
  color: var(--color-text);
  font: inherit;
  font-size: 13px;
  padding: 10px 12px;
  text-align: left;
}

.mention-avatar {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.mention-username {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.attach-panel {
  padding: 10px 12px 0;
}

.attach-preview {
  display: flex;
  gap: 6px;
  padding: 10px 12px 0;
}

.attach-preview img {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  object-fit: cover;
}

.composer {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px calc(10px + env(safe-area-inset-bottom));
  border-top: 1px solid var(--color-border);
}

.attach-btn {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  border: none;
  background: none;
  color: var(--color-text-muted);
  display: flex;
  align-items: center;
  justify-content: center;
}

.composer-input {
  flex: 1;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 10px 14px;
  font: inherit;
  font-size: 14px;
  background: var(--color-surface-input);
  color: var(--color-text);
}

.send-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  background: var(--color-primary);
  color: var(--color-on-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
</style>
