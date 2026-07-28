<script setup>
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import CreationHeader from '../components/create/CreationHeader.vue'
import PhotoPicker from '../components/create/PhotoPicker.vue'
import LocationPickerSheet from '../components/LocationPickerSheet.vue'
import { useUserLocation } from '../composables/useUserLocation'
import { useAuth } from '../composables/useAuth'
import { useCities, getCityById } from '../composables/useCities'

useCities()

const router = useRouter()
const { signUp } = useAuth()
const { state: locationState, openPicker, closePicker, setManualCity } = useUserLocation()

const username = ref('')
const email = ref('')
const password = ref('')
const avatar = ref([])
const isUploadingAvatar = ref(false)
const errors = reactive({})
const submitting = ref(false)
const needsEmailConfirmation = ref(false)

const selectedCityName = computed(() => getCityById(locationState.resolvedCityId)?.name || '')

function validate() {
  errors.username = username.value.trim() ? '' : 'Username is required'
  errors.email = email.value.trim() ? '' : 'Email is required'
  errors.password = password.value.length >= 6 ? '' : 'Password must be at least 6 characters'
  errors.location = locationState.resolvedCityId ? '' : 'Location is required'
  return !errors.username && !errors.email && !errors.password && !errors.location
}

async function submit() {
  if (!validate() || submitting.value || isUploadingAvatar.value) return
  submitting.value = true
  errors.form = ''

  const { error, needsEmailConfirmation: pending } = await signUp({
    email: email.value.trim(),
    password: password.value,
    username: username.value.trim(),
    location_city_id: locationState.resolvedCityId,
    avatarUrl: avatar.value[0] ?? null,
  })

  submitting.value = false
  if (error) {
    errors.form = error.message
    return
  }
  if (pending) {
    needsEmailConfirmation.value = true
    return
  }
  router.replace('/')
}
</script>

<template>
  <div class="form-screen">
    <CreationHeader title="Create Account" />

    <div v-if="needsEmailConfirmation" class="confirm-notice">
      <p>Check your email to confirm your account, then log in.</p>
      <button class="btn btn-primary" @click="router.replace('/login')">Go to Login</button>
    </div>

    <template v-else>
      <div class="form-step">
        <div class="field">
          <label class="field-label">Profile photo (optional)</label>
          <PhotoPicker v-model="avatar" v-model:uploading="isUploadingAvatar" :max="1" folder="avatars" />
        </div>

        <div class="field">
          <label class="field-label">Username</label>
          <input
            v-model="username"
            class="field-input"
            :class="{ 'field-input--error': errors.username }"
            placeholder="e.g. bang_gowes"
          />
          <span v-if="errors.username" class="field-error">{{ errors.username }}</span>
        </div>

        <div class="field">
          <label class="field-label">Email</label>
          <input
            v-model="email"
            type="email"
            class="field-input"
            :class="{ 'field-input--error': errors.email }"
            placeholder="you@example.com"
          />
          <span v-if="errors.email" class="field-error">{{ errors.email }}</span>
        </div>

        <div class="field">
          <label class="field-label">Password</label>
          <input
            v-model="password"
            type="password"
            class="field-input"
            :class="{ 'field-input--error': errors.password }"
            placeholder="••••••••"
          />
          <span v-if="errors.password" class="field-error">{{ errors.password }}</span>
        </div>

        <div class="field">
          <label class="field-label">City / location</label>
          <button
            type="button"
            class="field-input location-trigger"
            :class="{ 'field-input--error': errors.location }"
            @click="openPicker"
          >
            <span>{{ selectedCityName || 'Choose your city' }}</span>
            <Icon icon="iconoir:nav-arrow-right" width="16" height="16" />
          </button>
          <span v-if="errors.location" class="field-error">{{ errors.location }}</span>
        </div>

        <span v-if="errors.form" class="field-error">{{ errors.form }}</span>
      </div>

      <footer class="form-footer">
        <button class="btn btn-secondary" @click="router.push('/login')">Cancel</button>
        <button class="btn btn-primary" :disabled="submitting || isUploadingAvatar" @click="submit">
          {{ submitting ? 'Creating…' : 'Create Account' }}
        </button>
      </footer>
    </template>

    <LocationPickerSheet
      :open="locationState.isPickerOpen"
      :model-value="locationState.resolvedCityId"
      @update:model-value="setManualCity"
      @close="closePicker"
    />
  </div>
</template>

<style scoped>
.location-trigger {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  color: var(--color-text);
  text-align: left;
}

.confirm-notice {
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  align-items: center;
  text-align: center;
  color: var(--color-text-muted);
}
</style>
