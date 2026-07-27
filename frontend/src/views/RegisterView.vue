<script setup>
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import CreationHeader from '../components/create/CreationHeader.vue'
import PhotoPicker from '../components/create/PhotoPicker.vue'
import LocationPickerSheet from '../components/LocationPickerSheet.vue'
import { useUserLocation } from '../composables/useUserLocation'
import { getCityById } from '../mocks'

const router = useRouter()
const { state: locationState, openPicker, closePicker, setManualCity } = useUserLocation()

const username = ref('')
const email = ref('')
const password = ref('')
const avatar = ref([])
const errors = reactive({})

const selectedCityName = computed(() => getCityById(locationState.resolvedCityId)?.name || '')

function validate() {
  errors.username = username.value.trim() ? '' : 'Username is required'
  errors.email = email.value.trim() ? '' : 'Email is required'
  errors.password = password.value.length >= 6 ? '' : 'Password must be at least 6 characters'
  errors.location = locationState.resolvedCityId ? '' : 'Location is required'
  return !errors.username && !errors.email && !errors.password && !errors.location
}

function submit() {
  if (!validate()) return
  // Mock only — no backend exists yet (Phase 2). Always signs in as the seeded currentUser.
  router.replace('/')
}
</script>

<template>
  <div class="form-screen">
    <CreationHeader title="Create Account" />

    <div class="form-step">
      <div class="field">
        <label class="field-label">Profile photo (optional)</label>
        <PhotoPicker v-model="avatar" :max="1" />
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
    </div>

    <footer class="form-footer">
      <button class="btn btn-secondary" @click="router.push('/login')">Cancel</button>
      <button class="btn btn-primary" @click="submit">Create Account</button>
    </footer>

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
</style>
