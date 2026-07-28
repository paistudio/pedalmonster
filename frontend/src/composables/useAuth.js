import { reactive } from 'vue'
import { supabase } from '../lib/supabase'
import { getRankForPoints } from '../mocks/rank'

// Real auth/profile state, replacing the mocks/users.js stand-in per
// docs/19-supabase-only-backend-plan.md. `currentUser` mirrors the same shape the mock used
// (id, username, avatar_url, points, rank, ...) so downstream components migrate with minimal
// shape changes as each screen is wired up.
const state = reactive({
  session: null,
  currentUser: null,
  initialized: false,
})

async function loadProfile(userId) {
  const { data, error } = await supabase.from('profiles').select('*').eq('id', userId).single()
  if (error) {
    state.currentUser = null
    return
  }
  state.currentUser = { ...data, rank: getRankForPoints(data.points) }
}

supabase.auth.onAuthStateChange((_event, session) => {
  state.session = session
  if (session) loadProfile(session.user.id)
  else state.currentUser = null
})

async function init() {
  if (state.initialized) return
  const { data } = await supabase.auth.getSession()
  state.session = data.session
  if (data.session) await loadProfile(data.session.user.id)
  state.initialized = true
}

async function signUp({ email, password, username, location_city_id, avatarUrl }) {
  const { data, error } = await supabase.auth.signUp({ email, password })
  if (error) return { error }

  // A placeholder profiles row already exists (handle_new_user trigger) — overwrite it with
  // the real chosen values from the registration form. Only possible when signUp returned a
  // session immediately (email confirmation disabled) — otherwise there's nothing to update
  // yet since the JWT-authenticated RLS policy needs a live session.
  if (data.session) {
    await supabase
      .from('profiles')
      .update({ username, location_city_id, avatar_url: avatarUrl })
      .eq('id', data.user.id)
    await loadProfile(data.user.id)
  }

  return { data, needsEmailConfirmation: !data.session }
}

async function signIn({ email, password }) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password })
  return { data, error }
}

async function signOut() {
  await supabase.auth.signOut()
}

export function useAuth() {
  return { state, init, signUp, signIn, signOut }
}
