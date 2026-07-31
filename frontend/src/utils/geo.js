import { getCityById } from '../composables/useCities'

const EARTH_RADIUS_KM = 6371

// Fixed "nearby" radius used across Home's Nearby tab and Popular Near You — not user-configurable, see docs/17-regional-location.md
export const NEARBY_RADIUS_KM = 50

export function haversineDistanceKm(lat1, lng1, lat2, lng2) {
  const toRad = (deg) => (deg * Math.PI) / 180
  const dLat = toRad(lat2 - lat1)
  const dLng = toRad(lng2 - lng1)
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2
  return EARTH_RADIUS_KM * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

export function distanceBetweenCities(cityIdA, cityIdB) {
  const a = getCityById(cityIdA)
  const b = getCityById(cityIdB)
  if (!a || !b) return null
  return haversineDistanceKm(a.lat, a.lng, b.lat, b.lng)
}

export function nearestCity(lat, lng, cities) {
  let closest = null
  let closestDistance = Infinity
  for (const city of cities) {
    const distance = haversineDistanceKm(lat, lng, city.lat, city.lng)
    if (distance < closestDistance) {
      closestDistance = distance
      closest = city
    }
  }
  return closest
}

export function formatDistance(km) {
  if (km == null) return ''
  if (km < 1) return '<1 km away'
  if (km < 10) return `${km.toFixed(1)} km away`
  return `${Math.round(km)} km away`
}

// Resolves the device's GPS position to the nearest entry in `cities`.
// Rejects with { code: 'unsupported' | 'denied' | 'error' } — never throws a raw browser error.
export function requestGeolocationCity(cities) {
  return new Promise((resolve, reject) => {
    if (!('geolocation' in navigator)) {
      reject({ code: 'unsupported' })
      return
    }
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const city = nearestCity(position.coords.latitude, position.coords.longitude, cities)
        if (!city) {
          reject({ code: 'error' })
          return
        }
        resolve(city)
      },
      (error) => {
        reject({ code: error.code === error.PERMISSION_DENIED ? 'denied' : 'error' })
      },
      // Without an explicit timeout, a weak/no GPS fix (common indoors) leaves the browser's
      // default behavior undefined — some never call either callback, which reads as the
      // button being stuck on "Locating..." forever. 10s is generous for a first fix without
      // hanging indefinitely; maximumAge lets a very recent cached fix resolve instantly
      // instead of forcing a fresh one every time the sheet opens.
      { timeout: 10000, maximumAge: 60000 },
    )
  })
}
