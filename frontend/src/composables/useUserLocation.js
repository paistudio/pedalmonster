import { reactive } from 'vue'
import { findCityByName, getCityById, currentUser } from '../mocks'

// Module-singleton: the current user's own resolved location, used wherever
// "my location" matters (Home feed pill/Nearby tab, Marketplace default,
// Register, Account Settings). NOT for picking an arbitrary location on a
// listing/group being created — those use LocationPickerSheet directly with
// their own local state, since that location isn't the viewer's own.
const state = reactive({
  resolvedCityId: currentUser.location_city_id || findCityByName(currentUser.location)?.id || null,
  isPickerOpen: false,
})

export function useUserLocation() {
  function openPicker() {
    state.isPickerOpen = true
  }

  function closePicker() {
    state.isPickerOpen = false
  }

  function setManualCity(cityId) {
    const city = getCityById(cityId)
    if (!city) return
    state.resolvedCityId = city.id
    currentUser.location_city_id = city.id
    currentUser.location = city.name
  }

  return {
    state,
    openPicker,
    closePicker,
    setManualCity,
  }
}
