import { reactive, watch } from 'vue'
import { useAuth } from './useAuth'
import { useCities, getCityById, findCityByName } from './useCities'
import { supabase } from '../lib/supabase'

// Module-singleton: the current user's own resolved location, used wherever
// "my location" matters (Home feed pill/Nearby tab, Marketplace default,
// Register, Account Settings). NOT for picking an arbitrary location on a
// listing/group being created — those use LocationPickerSheet directly with
// their own local state, since that location isn't the viewer's own.
const state = reactive({
  resolvedCityId: null,
  isPickerOpen: false,
})

const { state: authState } = useAuth()
useCities()

// Re-resolve whenever the profile loads/changes (e.g. right after login).
watch(
  () => authState.currentUser,
  (user) => {
    if (!user) return
    state.resolvedCityId = user.location_city_id || findCityByName(user.location)?.id || null
  },
  { immediate: true },
)

export function useUserLocation() {
  function openPicker() {
    state.isPickerOpen = true
  }

  function closePicker() {
    state.isPickerOpen = false
  }

  async function setManualCity(cityId) {
    const city = getCityById(cityId)
    if (!city) return
    state.resolvedCityId = city.id

    if (authState.currentUser) {
      authState.currentUser.location_city_id = city.id
      authState.currentUser.location = city.name
      await supabase
        .from('profiles')
        .update({ location_city_id: city.id, location: city.name })
        .eq('id', authState.currentUser.id)
    }
  }

  return {
    state,
    openPicker,
    closePicker,
    setManualCity,
  }
}
