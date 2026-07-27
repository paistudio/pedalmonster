// City entity per docs/02-data-model.md — canonical location reference list, see docs/17-regional-location.md
export const cities = [
  { id: 'city-bandung', name: 'Bandung', province: 'Jawa Barat', lat: -6.9175, lng: 107.6191 },
  { id: 'city-cimahi', name: 'Cimahi', province: 'Jawa Barat', lat: -6.8841, lng: 107.5413 },
  { id: 'city-bogor', name: 'Bogor', province: 'Jawa Barat', lat: -6.5971, lng: 106.806 },
  { id: 'city-depok', name: 'Depok', province: 'Jawa Barat', lat: -6.4025, lng: 106.7942 },
  { id: 'city-jakarta-selatan', name: 'Jakarta Selatan', province: 'DKI Jakarta', lat: -6.2615, lng: 106.8106 },
  { id: 'city-jakarta-timur', name: 'Jakarta Timur', province: 'DKI Jakarta', lat: -6.225, lng: 106.9004 },
  { id: 'city-jakarta-pusat', name: 'Jakarta Pusat', province: 'DKI Jakarta', lat: -6.1805, lng: 106.8284 },
  { id: 'city-jakarta-utara', name: 'Jakarta Utara', province: 'DKI Jakarta', lat: -6.1214, lng: 106.8393 },
  { id: 'city-jakarta-barat', name: 'Jakarta Barat', province: 'DKI Jakarta', lat: -6.1352, lng: 106.8133 },
  { id: 'city-yogyakarta', name: 'Yogyakarta', province: 'DI Yogyakarta', lat: -7.7956, lng: 110.3695 },
  { id: 'city-surabaya', name: 'Surabaya', province: 'Jawa Timur', lat: -7.2575, lng: 112.7521 },
  { id: 'city-malang', name: 'Malang', province: 'Jawa Timur', lat: -7.9666, lng: 112.6326 },
  { id: 'city-semarang', name: 'Semarang', province: 'Jawa Tengah', lat: -6.9932, lng: 110.4203 },
  { id: 'city-solo', name: 'Solo', province: 'Jawa Tengah', lat: -7.5755, lng: 110.8243 },
]

// Aliases for free-text location strings that predate the canonical city list.
const ALIASES = {
  'south jakarta': 'city-jakarta-selatan',
  'east jakarta': 'city-jakarta-timur',
  'north jakarta': 'city-jakarta-utara',
  'west jakarta': 'city-jakarta-barat',
  'central jakarta': 'city-jakarta-pusat',
}

export function getCityById(id) {
  return cities.find((city) => city.id === id)
}

export function findCityByName(name) {
  if (!name) return null
  const key = name.trim().toLowerCase()
  const aliasId = ALIASES[key]
  if (aliasId) return getCityById(aliasId)
  return cities.find((city) => city.name.toLowerCase() === key) || null
}
