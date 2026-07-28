<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import BottomSheet from './BottomSheet.vue'
import { useAuth } from '../composables/useAuth'
import { avatarSrc } from '../utils/avatar'

const props = defineProps({
  open: { type: Boolean, required: true },
  users: { type: Array, required: true },
  title: { type: String, required: true },
  emptyText: { type: String, default: 'No one here yet.' },
  canModerate: { type: Boolean, default: false },
})
const emit = defineEmits(['close', 'block'])

const router = useRouter()
const { state: authState } = useAuth()
const pendingBlockId = ref(null)

function openProfile(user) {
  emit('close')
  router.push(`/profile/${user.id}`)
}

function requestBlock(userId) {
  pendingBlockId.value = userId
}

function cancelBlock() {
  pendingBlockId.value = null
}

function confirmBlock(userId) {
  emit('block', userId)
  pendingBlockId.value = null
}
</script>

<template>
  <BottomSheet :open="open" @close="$emit('close')">
    <h2 class="sheet-title">{{ title }}</h2>
    <div class="user-list">
      <div v-for="user in users" :key="user.id" class="user-row">
        <button class="user-row__identity" @click="openProfile(user)">
          <img class="avatar" :src="avatarSrc(user)" :alt="user.username" />
          <span class="username">{{ user.username }}</span>
        </button>

        <template v-if="canModerate && user.id !== authState.currentUser?.id">
          <div v-if="pendingBlockId === user.id" class="block-confirm">
            <button class="block-confirm__cancel" @click="cancelBlock">Cancel</button>
            <button class="block-confirm__confirm" @click="confirmBlock(user.id)">Block</button>
          </div>
          <button v-else class="block-trigger" @click="requestBlock(user.id)">Block</button>
        </template>
      </div>
      <p v-if="!users.length" class="empty">{{ emptyText }}</p>
    </div>
  </BottomSheet>
</template>

<style scoped>
.sheet-title {
  font-size: 16px;
  margin: 0 0 12px;
  text-align: center;
}

.user-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 50vh;
  overflow-y: auto;
}

.user-row {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
}

.user-row__identity {
  flex: 1;
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 10px;
  border: none;
  background: none;
  color: inherit;
  font: inherit;
  text-align: left;
  padding: 0;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.username {
  flex: 1;
  font-size: 14px;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.block-trigger {
  flex-shrink: 0;
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-error);
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
}

.block-confirm {
  flex-shrink: 0;
  display: flex;
  gap: 6px;
}

.block-confirm__cancel {
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text);
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
}

.block-confirm__confirm {
  border: 1px solid var(--color-error);
  background: var(--color-error);
  color: #ffffff;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 16px 0;
}
</style>
