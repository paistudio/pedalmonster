<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('')
const password = ref('')
const errors = reactive({})

function validate() {
  errors.email = email.value.trim() ? '' : 'Email is required'
  errors.password = password.value ? '' : 'Password is required'
  return !errors.email && !errors.password
}

function submit() {
  if (!validate()) return
  // Mock only — no backend exists yet (Phase 2). Always signs in as the seeded currentUser.
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
        />
        <span v-if="errors.password" class="field-error">{{ errors.password }}</span>
      </div>

      <button class="btn btn-primary auth-submit" @click="submit">Log In</button>

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
