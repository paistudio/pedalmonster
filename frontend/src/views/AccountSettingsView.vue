<script setup>
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import LocationPickerSheet from '../components/LocationPickerSheet.vue'
import { useUserLocation } from '../composables/useUserLocation'
import { currentUser, getCityById } from '../mocks'

const router = useRouter()
const { state: locationState, openPicker, closePicker, setManualCity } = useUserLocation()

const avatarInput = ref(null)

function onAvatarSelected(e) {
  const file = e.target.files?.[0]
  if (!file) return
  currentUser.avatar_url = URL.createObjectURL(file)
  e.target.value = ''
}

const account = reactive({
  username: currentUser.username,
  email: currentUser.email,
})
const accountErrors = reactive({})
const accountSaved = ref(false)

const selectedCityName = computed(() => getCityById(locationState.resolvedCityId)?.name || '')

const password = reactive({
  current: '',
  next: '',
  confirm: '',
})
const passwordErrors = reactive({})
const passwordSaved = ref(false)

function saveAccount() {
  accountErrors.username = account.username.trim() ? '' : 'Username is required'
  accountErrors.email = account.email.trim() ? '' : 'Email is required'
  if (accountErrors.username || accountErrors.email) return

  currentUser.username = account.username.trim()
  currentUser.email = account.email.trim()
  accountSaved.value = true
  passwordSaved.value = false
  setTimeout(() => (accountSaved.value = false), 2500)
}

function updatePassword() {
  passwordErrors.current = password.current ? '' : 'Current password is required'
  passwordErrors.next = password.next.length >= 8 ? '' : 'New password must be at least 8 characters'
  passwordErrors.confirm = password.next === password.confirm ? '' : 'Passwords do not match'
  if (passwordErrors.current || passwordErrors.next || passwordErrors.confirm) return

  password.current = ''
  password.next = ''
  password.confirm = ''
  passwordSaved.value = true
  accountSaved.value = false
  setTimeout(() => (passwordSaved.value = false), 2500)
}
</script>

<template>
  <div class="settings-screen">
    <header class="screen-header">
      <button class="icon-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <span class="screen-title">Account Settings</span>
      <div class="spacer" />
    </header>

    <div class="settings-body">
      <section class="settings-section avatar-section">
        <button class="avatar-trigger" aria-label="Change profile photo" @click="avatarInput.click()">
          <img class="avatar-preview" :src="currentUser.avatar_url" :alt="currentUser.username" />
          <span class="avatar-edit-badge">
            <Icon icon="iconoir:camera" width="14" height="14" />
          </span>
        </button>
        <button class="avatar-change-link" @click="avatarInput.click()">Change photo</button>
        <input ref="avatarInput" type="file" accept="image/*" class="hidden-input" @change="onAvatarSelected" />
      </section>

      <div class="settings-divider" />

      <section class="settings-section">
        <p class="settings-label">Account information</p>

        <div class="field">
          <label class="field-label">Username</label>
          <input
            v-model="account.username"
            class="field-input"
            :class="{ 'field-input--error': accountErrors.username }"
          />
          <span v-if="accountErrors.username" class="field-error">{{ accountErrors.username }}</span>
        </div>

        <div class="field">
          <label class="field-label">Email</label>
          <input
            v-model="account.email"
            type="email"
            class="field-input"
            :class="{ 'field-input--error': accountErrors.email }"
          />
          <span v-if="accountErrors.email" class="field-error">{{ accountErrors.email }}</span>
        </div>

        <div class="field">
          <label class="field-label">Location</label>
          <button type="button" class="field-input location-trigger" @click="openPicker">
            <span>{{ selectedCityName || 'Set your location' }}</span>
            <Icon icon="iconoir:nav-arrow-right" width="16" height="16" />
          </button>
        </div>

        <button class="btn btn-primary" @click="saveAccount">Save changes</button>
        <p v-if="accountSaved" class="save-confirm">Account information updated.</p>
      </section>

      <LocationPickerSheet
        :open="locationState.isPickerOpen"
        :model-value="locationState.resolvedCityId"
        @update:model-value="setManualCity"
        @close="closePicker"
      />

      <div class="settings-divider" />

      <section class="settings-section">
        <p class="settings-label">Change password</p>

        <div class="field">
          <label class="field-label">Current password</label>
          <input
            v-model="password.current"
            type="password"
            class="field-input"
            :class="{ 'field-input--error': passwordErrors.current }"
            placeholder="••••••••"
          />
          <span v-if="passwordErrors.current" class="field-error">{{ passwordErrors.current }}</span>
        </div>

        <div class="field">
          <label class="field-label">New password</label>
          <input
            v-model="password.next"
            type="password"
            class="field-input"
            :class="{ 'field-input--error': passwordErrors.next }"
            placeholder="••••••••"
          />
          <span v-if="passwordErrors.next" class="field-error">{{ passwordErrors.next }}</span>
        </div>

        <div class="field">
          <label class="field-label">Confirm new password</label>
          <input
            v-model="password.confirm"
            type="password"
            class="field-input"
            :class="{ 'field-input--error': passwordErrors.confirm }"
            placeholder="••••••••"
          />
          <span v-if="passwordErrors.confirm" class="field-error">{{ passwordErrors.confirm }}</span>
        </div>

        <button class="btn btn-primary" @click="updatePassword">Update password</button>
        <p v-if="passwordSaved" class="save-confirm">Password updated.</p>
      </section>
    </div>
  </div>
</template>

<style scoped>
.settings-screen {
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

.settings-body {
  flex: 1;
  overflow-y: auto;
  padding: 4px 16px 24px;
}

.settings-section {
  display: flex;
  flex-direction: column;
  gap: 14px;
  padding: 12px 0;
}

.settings-label {
  font-family: var(--font-mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 1.2px;
  color: var(--color-text-muted);
  margin: 0;
}

.settings-divider {
  height: 1px;
  background: var(--color-border);
}

.btn {
  flex: none;
  width: 100%;
}

.location-trigger {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  color: var(--color-text);
  text-align: left;
}

.save-confirm {
  font-size: 12px;
  color: var(--color-accent-alt);
  margin: 0;
}

.avatar-section {
  align-items: center;
  gap: 8px;
}

.avatar-trigger {
  position: relative;
  width: 72px;
  height: 72px;
  border: none;
  background: none;
  padding: 0;
  border-radius: 50%;
}

.avatar-preview {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  object-fit: cover;
  display: block;
}

.avatar-edit-badge {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: rgba(54, 58, 63, 0.9);
  border: none;
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-change-link {
  border: none;
  background: none;
  color: var(--color-accent-alt);
  font-size: 13px;
  padding: 0;
}

.hidden-input {
  display: none;
}
</style>
