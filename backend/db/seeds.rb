# Canonical city reference list, per docs/17-regional-location.md — kept in sync with the
# Phase 1 mock at frontend/src/mocks/cities.js (that file's string ids are Phase-1-only
# convenience keys, not real UUIDs, so we match on name+province instead).
CITIES = [
  { name: "Bandung", province: "Jawa Barat", lat: -6.9175, lng: 107.6191 },
  { name: "Cimahi", province: "Jawa Barat", lat: -6.8841, lng: 107.5413 },
  { name: "Bogor", province: "Jawa Barat", lat: -6.5971, lng: 106.806 },
  { name: "Depok", province: "Jawa Barat", lat: -6.4025, lng: 106.7942 },
  { name: "Jakarta Selatan", province: "DKI Jakarta", lat: -6.2615, lng: 106.8106 },
  { name: "Jakarta Timur", province: "DKI Jakarta", lat: -6.225, lng: 106.9004 },
  { name: "Jakarta Pusat", province: "DKI Jakarta", lat: -6.1805, lng: 106.8284 },
  { name: "Jakarta Utara", province: "DKI Jakarta", lat: -6.1214, lng: 106.8393 },
  { name: "Jakarta Barat", province: "DKI Jakarta", lat: -6.1352, lng: 106.8133 },
  { name: "Yogyakarta", province: "DI Yogyakarta", lat: -7.7956, lng: 110.3695 },
  { name: "Surabaya", province: "Jawa Timur", lat: -7.2575, lng: 112.7521 },
  { name: "Malang", province: "Jawa Timur", lat: -7.9666, lng: 112.6326 },
  { name: "Semarang", province: "Jawa Tengah", lat: -6.9932, lng: 110.4203 },
  { name: "Solo", province: "Jawa Tengah", lat: -7.5755, lng: 110.8243 }
].freeze

CITIES.each do |attrs|
  City.find_or_create_by!(name: attrs[:name], province: attrs[:province]) do |city|
    city.lat = attrs[:lat]
    city.lng = attrs[:lng]
  end
end

puts "Seeded #{City.count} cities"
