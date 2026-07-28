<script setup>
import { ref } from 'vue'
import { Icon } from '@iconify/vue'
import BottomSheet from './BottomSheet.vue'
import { supabase } from '../lib/supabase'
import { useAuth } from '../composables/useAuth'

const props = defineProps({
  open: { type: Boolean, required: true },
  postId: { type: String, required: true },
})
const emit = defineEmits(['close'])

const { state: authState } = useAuth()

const REASONS = [
  { value: 'spam', label: 'Spam' },
  { value: 'content', label: 'Inappropriate content' },
  { value: 'harassment', label: 'Harassment or bullying' },
  { value: 'other', label: 'Other' },
]

const reason = ref('')
const submitted = ref(false)

// Post reports are reason-only in MVP (no free-text field) — description is null,
// see docs/02-data-model.md's Report entity.
async function submit() {
  if (!reason.value || !authState.currentUser) return
  const { error } = await supabase.from('reports').insert({
    user_id: authState.currentUser.id,
    post_id: props.postId,
    category: reason.value,
  })
  if (error) return
  submitted.value = true
}

function close() {
  emit('close')
  // Reset after the sheet's close transition finishes.
  setTimeout(() => {
    reason.value = ''
    submitted.value = false
  }, 250)
}
</script>

<template>
  <BottomSheet :open="open" @close="close">
    <div v-if="submitted" class="report-success">
      <Icon icon="iconoir:check-circle" width="32" height="32" />
      <p class="success-title">Report sent</p>
      <p class="success-body">Thanks for letting us know — our team will take a look.</p>
      <button class="btn btn-secondary" @click="close">Done</button>
    </div>

    <template v-else>
      <h2 class="sheet-title">Report post</h2>
      <div class="reason-list">
        <label v-for="opt in REASONS" :key="opt.value" class="reason-option">
          <input v-model="reason" type="radio" name="report-reason" :value="opt.value" />
          {{ opt.label }}
        </label>
      </div>
      <div class="sheet-actions">
        <button class="btn btn-secondary" @click="close">Cancel</button>
        <button class="btn btn-primary" :disabled="!reason" @click="submit">Submit report</button>
      </div>
    </template>
  </BottomSheet>
</template>

<style scoped>
.sheet-title {
  font-size: 16px;
  margin: 4px 0 12px;
}

.reason-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 16px;
}

.reason-option {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 4px;
  font-size: 14px;
  color: var(--color-text);
}

.sheet-actions {
  display: flex;
  gap: 10px;
  padding-bottom: 4px;
}

.report-success {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 12px 4px 4px;
  text-align: center;
  color: var(--color-text);
}

.success-title {
  font-size: 15px;
  margin: 4px 0 0;
}

.success-body {
  font-size: 13px;
  color: var(--color-text-muted);
  margin: 0 0 12px;
}

.report-success .btn {
  width: auto;
  padding-left: 24px;
  padding-right: 24px;
}
</style>
