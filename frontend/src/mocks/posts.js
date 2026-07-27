// Post entity (base + polymorphic type_data) per docs/02-data-model.md.
// parent_id is always null here — these are top-level posts. Comments (type='comment',
// parent_id set) live in ./comments.js, seeded separately for readability but sharing
// this same Post shape.
export const posts = [
  // --- listing ---
  {
    id: 'p1',
    user_id: 'u1',
    type: 'listing',
    parent_id: null,
    title: 'Sepeda MTB Polygon Xtrada 7, size M',
    description:
      'Kondisi 90%, jarang dipakai, upgrade fork sudah tapered. Rantai dan gear set baru diganti bulan lalu, ban masih tebal. Nego halus, serius aja yang chat. Bisa COD area Bandung Utara.',
    tags: ['MTB', 'Trail'],
    media_urls: [
      'https://picsum.photos/seed/listing-mtb-1/600/600',
      'https://picsum.photos/seed/listing-mtb-2/600/600',
    ],
    location: 'Bandung',
    location_city_id: 'city-bandung',
    like_count: 18,
    created_at: '2026-07-20T03:12:00Z',
    type_data: {
      category: 'bike',
      condition: 'used',
      price: 4500000,
      status: 'available',
    },
  },
  {
    id: 'p2',
    user_id: 'u8',
    type: 'listing',
    parent_id: null,
    title: 'Groupset Shimano Deore 1x11 second',
    description: 'Lengkap shifter, RD, crank. Baru copot, masih mulus.',
    tags: ['Commuter'],
    media_urls: ['https://picsum.photos/seed/listing-groupset/600/600'],
    location: 'Jakarta Timur',
    location_city_id: 'city-jakarta-timur',
    like_count: 6,
    created_at: '2026-07-22T09:40:00Z',
    type_data: {
      category: 'part',
      condition: 'used',
      price: 1250000,
      status: 'available',
    },
  },
  {
    id: 'p3',
    user_id: 'u6',
    type: 'listing',
    parent_id: null,
    title: 'Sadel Fizik brand new, belum pernah pasang',
    description: 'Salah beli ukuran, jual rugi.',
    media_urls: ['https://picsum.photos/seed/listing-saddle/600/600'],
    location: 'Bogor',
    location_city_id: 'city-bogor',
    like_count: 3,
    created_at: '2026-07-23T13:05:00Z',
    type_data: {
      category: 'part',
      condition: 'new',
      price: 650000,
      status: 'sold',
    },
  },

  // --- community_post (no title — see docs/06-post-creation-flow.md) ---
  {
    id: 'p7',
    user_id: 'u4',
    type: 'community_post',
    parent_id: null,
    title: null,
    description:
      'Rekomendasi ban tubeless buat MTB pemula? Budget 500rb-an, dipakai buat trail ringan sama commuting.',
    tags: ['MTB', 'Trail'],
    media_urls: [],
    location: null,
    like_count: 9,
    created_at: '2026-07-22T02:30:00Z',
    type_data: {},
  },
  {
    id: 'p8',
    user_id: 'u5',
    type: 'community_post',
    parent_id: null,
    title: null,
    description:
      'Cara setel rem cakram hidrolik yang bunyi gesek ya? Rem depan bunyi terus padahal udah dibersihin rotornya.',
    tags: ['Maintenance'],
    media_urls: ['https://picsum.photos/seed/question-brake/600/600'],
    location: null,
    like_count: 4,
    created_at: '2026-07-23T08:15:00Z',
    type_data: {},
  },
  {
    id: 'p9',
    user_id: 'u3',
    type: 'community_post',
    parent_id: null,
    title: null,
    description: 'Fixie buat commuting harian, worth it gak sih? Jarak rumah-kantor 8km, medan agak nanjak dikit.',
    tags: ['Commuter'],
    media_urls: [],
    location: null,
    like_count: 1,
    created_at: '2026-07-24T01:00:00Z',
    type_data: {},
  },

  // --- group_post ---
  {
    id: 'p10',
    user_id: 'u1',
    type: 'group_post',
    parent_id: null,
    title: 'Rekap rute gowes minggu lalu',
    description: 'Terima kasih buat yang udah ikut, foto-foto ada di album grup ya!',
    tags: ['Group Ride'],
    media_urls: ['https://picsum.photos/seed/grouppost-recap/600/600'],
    location: 'Bandung',
    location_city_id: 'city-bandung',
    like_count: 11,
    created_at: '2026-07-21T12:00:00Z',
    type_data: {
      group_id: 'g1',
    },
  },
  {
    id: 'p11',
    user_id: 'u6',
    type: 'group_post',
    parent_id: null,
    title: 'Info maintenance rutin sebelum trail day',
    description: 'Cek tekanan suspensi dan baut-baut sebelum ikut sesi Sabtu ini.',
    tags: ['Trail'],
    media_urls: [],
    location: null,
    like_count: 2,
    created_at: '2026-07-23T15:30:00Z',
    type_data: {
      group_id: 'g2',
    },
  },
]

export function getPostById(id) {
  return posts.find((post) => post.id === id)
}

export function getPostsByType(type) {
  return posts.filter((post) => post.type === type)
}

// Held out of the initial feed — surfaced by pull-to-refresh to demo new content arriving.
export const incomingPost = {
  id: 'p12',
  user_id: 'u2',
  type: 'listing',
  parent_id: null,
  title: 'Jersey tim lokal, size L, baru dipakai sekali',
  description: 'Warna masih cerah, dijual karena kekecilan. Bisa nego di tempat.',
  media_urls: ['https://picsum.photos/seed/listing-jersey/600/600'],
  location: 'Jakarta Selatan',
  location_city_id: 'city-jakarta-selatan',
  like_count: 0,
  created_at: new Date().toISOString(),
  type_data: {
    category: 'part',
    condition: 'used',
    price: 175000,
    status: 'available',
  },
}
