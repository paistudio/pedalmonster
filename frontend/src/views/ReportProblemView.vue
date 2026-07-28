<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import { supabase } from '../lib/supabase'
import { useAuth } from '../composables/useAuth'

const router = useRouter()
const { state: authState } = useAuth()

const CATEGORIES = [
  { value: 'bug', label: 'Something is broken' },
  { value: 'content', label: 'Inappropriate content' },
  { value: 'account', label: 'Account issue' },
  { value: 'other', label: 'Other' },
]

const category = ref('')
const description = ref('')
const errors = reactive({})
const submitted = ref(false)

async function submit() {
  errors.category = category.value ? '' : 'Pick a category'
  errors.description = description.value.trim() ? '' : 'Tell us what happened'
  if (errors.category || errors.description) return
  if (!authState.currentUser) return

  const { error } = await supabase.from('reports').insert({
    user_id: authState.currentUser.id,
    category: category.value,
    description: description.value.trim(),
  })
  if (error) return
  submitted.value = true
}
</script>

<template>
  <div class="report-screen">
    <header class="screen-header">
      <button class="icon-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <span class="screen-title">Report a problem</span>
      <div class="spacer" />
    </header>

    <div v-if="submitted" class="report-success">
      <Icon icon="iconoir:check-circle" width="40" height="40" />
      <p class="success-title">Report sent</p>
      <p class="success-body">Thanks for letting us know — our team will take a look.</p>
      <button class="btn btn-primary" @click="router.push('/')">Back to Home</button>
    </div>

    <div v-else class="form-step">
      <div class="field">
        <label class="field-label">Category</label>
        <select v-model="category" class="field-select" :class="{ 'field-select--error': errors.category }">
          <option value="" disabled>Select a category</option>
          <option v-for="opt in CATEGORIES" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
        </select>
        <span v-if="errors.category" class="field-error">{{ errors.category }}</span>
      </div>

      <div class="field">
        <label class="field-label">What happened?</label>
        <textarea
          v-model="description"
          class="field-textarea"
          :class="{ 'field-textarea--error': errors.description }"
          placeholder="Describe the issue in as much detail as you can..."
        />
        <span v-if="errors.description" class="field-error">{{ errors.description }}</span>
      </div>

      <button class="btn btn-primary" @click="submit">Submit report</button>
    </div>
  </div>
</template>

<style scoped>
.report-screen {
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

.form-step {
  flex: 1;
  overflow-y: auto;
  padding: 4px 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.btn {
  flex: none;
  width: 100%;
}

.report-success {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 24px;
  text-align: center;
  color: var(--color-text);
}

.success-title {
  font-size: 16px;
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
