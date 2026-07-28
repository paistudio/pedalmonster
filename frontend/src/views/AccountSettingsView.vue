<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import LocationPickerSheet from '../components/LocationPickerSheet.vue'
import { useUserLocation } from '../composables/useUserLocation'
import { useCities, getCityById } from '../composables/useCities'
import { useAuth } from '../composables/useAuth'
import { useUpload } from '../composables/useUpload'
import { supabase } from '../lib/supabase'

const router = useRouter()
const { state: locationState, openPicker, closePicker, setManualCity } = useUserLocation()
const { state: authState } = useAuth()
const { uploadFile } = useUpload()
useCities()

const currentUser = computed(() => authState.currentUser || {})
const avatarInput = ref(null)

async function onAvatarSelected(e) {
  const file = e.target.files?.[0]
  e.target.value = ''
  if (!file || !authState.currentUser) return
  const avatarUrl = await uploadFile(file, 'avatars')
  const { error } = await supabase
    .from('profiles')
    .update({ avatar_url: avatarUrl })
    .eq('id', authState.currentUser.id)
  if (!error) authState.currentUser.avatar_url = avatarUrl
}

const account = reactive({ username: '', email: '' })
const accountErrors = reactive({})
const accountSaved = ref(false)

watch(
  () => authState.currentUser,
  (user) => {
    if (user) account.username = user.username
  },
  { immediate: true },
)
watch(
  () => authState.session,
  (session) => {
    account.email = session?.user?.email || ''
  },
  { immediate: true },
)

const selectedCityName = computed(() => getCityById(locationState.resolvedCityId)?.name || '')

const password = reactive({
  current: '',
  next: '',
  confirm: '',
})
const passwordErrors = reactive({})
const passwordSaved = ref(false)

async function saveAccount() {
  accountErrors.username = account.username.trim() ? '' : 'Username is required'
  accountErrors.email = account.email.trim() ? '' : 'Email is required'
  accountErrors.form = ''
  if (accountErrors.username || accountErrors.email) return

  const { error: profileError } = await supabase
    .from('profiles')
    .update({ username: account.username.trim() })
    .eq('id', authState.currentUser.id)
  if (profileError) {
    accountErrors.form = profileError.message
    return
  }
  authState.currentUser.username = account.username.trim()

  // email is Supabase-Auth-owned — a separate call even though it's presented as one form,
  // see docs/03-auth-user-profile.md.
  if (account.email.trim() !== authState.session?.user?.email) {
    const { error: emailError } = await supabase.auth.updateUser({ email: account.email.trim() })
    if (emailError) {
      accountErrors.form = emailError.message
      return
    }
  }

  accountSaved.value = true
  passwordSaved.value = false
  setTimeout(() => (accountSaved.value = false), 2500)
}

async function updatePassword() {
  passwordErrors.current = password.current ? '' : 'Current password is required'
  passwordErrors.next = password.next.length >= 8 ? '' : 'New password must be at least 8 characters'
  passwordErrors.confirm = password.next === password.confirm ? '' : 'Passwords do not match'
  passwordErrors.form = ''
  if (passwordErrors.current || passwordErrors.next || passwordErrors.confirm) return

  // updateUser doesn't itself check the current password, so re-auth first — see
  // docs/03-auth-user-profile.md.
  const { error: reauthError } = await supabase.auth.signInWithPassword({
    email: authState.session.user.email,
    password: password.current,
  })
  if (reauthError) {
    passwordErrors.current = 'Current password is incorrect'
    return
  }

  const { error } = await supabase.auth.updateUser({ password: password.next })
  if (error) {
    passwordErrors.form = error.message
    return
  }

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

        <span v-if="accountErrors.form" class="field-error">{{ accountErrors.form }}</span>
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

        <span v-if="passwordErrors.form" class="field-error">{{ passwordErrors.form }}</span>
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
