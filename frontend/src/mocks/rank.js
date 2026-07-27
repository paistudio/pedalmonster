// Rank tiers per docs/02-data-model.md
export const RANK_TIERS = [
  { rank: 'Cub', min: 0, max: 19 },
  { rank: 'Scout', min: 20, max: 49 },
  { rank: 'Rider', min: 50, max: 149 },
  { rank: 'Alpha', min: 150, max: 349 },
  { rank: 'Pedal Monster', min: 350, max: Infinity },
]

export function getRankForPoints(points) {
  return RANK_TIERS.find((tier) => points >= tier.min && points <= tier.max).rank
}
