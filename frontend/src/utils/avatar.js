// Falls back to the Pedal Monster mark on a neutral circle — design.md has no separate avatar
// placeholder spec, so this reuses the existing brand mark (frontend/public/avatar-placeholder.svg)
// rather than inventing a new asset. Also sidesteps a real bug: binding `:src` straight to a
// null/empty avatar_url left some `<img>` tags with no (or an empty) src, which is never what a
// user actually wants to render.
export const DEFAULT_AVATAR = '/avatar-placeholder.svg'

export function avatarSrc(user) {
  return user?.avatar_url || DEFAULT_AVATAR
}
