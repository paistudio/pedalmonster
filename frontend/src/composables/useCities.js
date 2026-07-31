import { reactive } from 'vue'
import { supabase } from '../lib/supabase'

// Real cities table, replacing mocks/cities.js per docs/19-supabase-only-backend-plan.md.
// Read-only reference data — fetched once and cached module-wide.
const state = reactive({ cities: [], loaded: false })

let loadPromise = null
function ensureLoaded() {
  if (state.loaded) return Promise.resolve()
  if (!loadPromise) {
    loadPromise = supabase
      .from('cities')
      .select('*')
      .order('name')
      .then(({ data, error }) => {
        if (!error) state.cities = data
        state.loaded = true
      })
  }
  return loadPromise
}

export function useCities() {
  ensureLoaded()
  return { state, ensureLoaded }
}

export function getCityById(id) {
  return state.cities.find((city) => city.id === id)
}

export function findCityByName(name) {
  if (!name) return null
  const key = name.trim().toLowerCase()
  return state.cities.find((city) => city.name.toLowerCase() === key) || null
}
