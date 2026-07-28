<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const router = useRouter()
const { signIn } = useAuth()
const email = ref('')
const password = ref('')
const errors = reactive({})
const submitting = ref(false)

function validate() {
  errors.email = email.value.trim() ? '' : 'Email is required'
  errors.password = password.value ? '' : 'Password is required'
  return !errors.email && !errors.password
}

async function submit() {
  if (!validate() || submitting.value) return
  submitting.value = true
  errors.form = ''

  const { error } = await signIn({ email: email.value.trim(), password: password.value })

  submitting.value = false
  if (error) {
    errors.form = error.message
    return
  }
  router.replace('/')
}
</script>

<template>
  <div class="auth-screen">
    <div class="auth-body">
      <h1 class="auth-title">Pedal Monster</h1>
      <p class="auth-subtitle">Log in to continue</p>

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
          @keyup.enter="submit"
        />
        <span v-if="errors.password" class="field-error">{{ errors.password }}</span>
      </div>

      <span v-if="errors.form" class="field-error">{{ errors.form }}</span>

      <button class="btn btn-primary auth-submit" :disabled="submitting" @click="submit">
        {{ submitting ? 'Logging in…' : 'Log In' }}
      </button>

      <p class="auth-switch">
        Don't have an account?
        <RouterLink to="/register" class="auth-link">Sign up</RouterLink>
      </p>
    </div>
  </div>
</template>

<style scoped>
.auth-screen {
  height: 100%;
  display: flex;
  align-items: center;
}

.auth-body {
  width: 100%;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.auth-title {
  font-size: 22px;
  margin: 0;
  text-align: center;
}

.auth-subtitle {
  font-size: 14px;
  color: var(--color-text-muted);
  text-align: center;
  margin: -8px 0 8px;
}

.auth-submit {
  margin-top: 4px;
}

.auth-switch {
  text-align: center;
  font-size: 13px;
  color: var(--color-text-muted);
  margin: 4px 0 0;
}

.auth-link {
  color: var(--color-text);
  text-decoration: underline;
}
</style>
