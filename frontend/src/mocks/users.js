import { reactive } from 'vue'
import { getRankForPoints } from './rank'

// User entity per docs/02-data-model.md
const rawUsers = [
  {
    id: 'u1',
    username: 'bang_gowes',
    email: 'bang.gowes@example.com',
    avatar_url: 'https://i.pravatar.cc/150?img=12',
    bio: 'Love early morning rides around Bandung. Buy/sell MTB parts.',
    location: 'Bandung',
    location_city_id: 'city-bandung',
    points: 412,
    created_at: '2024-11-02T07:00:00Z',
  },
  {
    id: 'u2',
    username: 'sepeda.rina',
    email: 'rina.sepeda@example.com',
    avatar_url: 'https://i.pravatar.cc/150?img=47',
    bio: 'Roadbike enthusiast, weekend warrior.',
    location: 'Jakarta Selatan',
    location_city_id: 'city-jakarta-selatan',
    points: 210,
    created_at: '2025-01-15T09:30:00Z',
  },
  {
    id: 'u3',
    username: 'fixie_jogja',
    email: 'fixie.jogja@example.com',
    avatar_url: 'https://i.pravatar.cc/150?img=33',
    bio: null,
    location: 'Yogyakarta',
    location_city_id: 'city-yogyakarta',
    points: 88,
    created_at: '2025-03-20T02:10:00Z',
  },
  {
    id: 'u4',
    username: 'dimas.ridewell',
    email: 'dimas.ridewell@example.com',
    avatar_url: 'https://i.pravatar.cc/150?img=5',
    bio: "Just getting into riding, still learning to do my own maintenance.",
    location: 'Depok',
    location_city_id: 'city-depok',
    points: 34,
    created_at: '2025-05-11T11:45:00Z',
  },
  {
    id: 'u5',
    username: 'kirana_bikes',
    email: 'kirana.bikes@example.com',
    avatar_url: 'https://i.pravatar.cc/150?img=25',
    bio: 'Komunitas gowes cewek Surabaya.',
    location: 'Surabaya',
    location_city_id: 'city-surabaya',
    points: 5,
    created_at: '2025-07-01T14:20:00Z',
  },
  {
    id: 'u6',
    username: 'omar_mtb',
    email: 'omar.mtb@example.com',
    avatar_url: 'https://i.pravatar.cc/150?img=8',
    bio: 'Downhill & trail, part collector.',
    location: 'Bogor',
    location_city_id: 'city-bogor',
    points: 168,
    created_at: '2024-08-19T05:15:00Z',
  },
  {
    id: 'u7',
    username: 'linda.gravel',
    email: 'linda.gravel@example.com',
    avatar_url: 'https://i.pravatar.cc/150?img=19',
    bio: 'Gravel rides every Sunday, DM for route sharing.',
    location: 'Bandung',
    location_city_id: 'city-bandung',
    points: 61,
    created_at: '2025-02-08T08:00:00Z',
  },
  {
    id: 'u8',
    username: 'topan_wrench',
    email: 'topan.wrench@example.com',
    avatar_url: 'https://i.pravatar.cc/150?img=14',
    bio: 'Tukang servis sepeda, jual part bekas berkualitas.',
    location: 'Jakarta Timur',
    location_city_id: 'city-jakarta-timur',
    points: 501,
    created_at: '2024-05-30T10:00:00Z',
  },
]

export const users = rawUsers.map((user) => ({
  ...user,
  rank: getRankForPoints(user.points),
}))

export function getUserById(id) {
  return users.find((user) => user.id === id)
}

// Stand-in for the logged-in user until auth (docs/03-auth-user-profile.md) lands.
// Reactive so points/rank update live in the UI when activity points are awarded.
export const currentUser = reactive(users[0])
users[0] = currentUser

// Activity points per docs/02-data-model.md
export function addPoints(amount) {
  currentUser.points += amount
  currentUser.rank = getRankForPoints(currentUser.points)
}
