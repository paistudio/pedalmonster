import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

const LOGO = fileURLToPath(new URL('../src/assets/pedalmonster-logo-icon.svg', import.meta.url))

// Subpath indices of the logo's single <path>, grouped into the parts the
// preloader animates independently. See docs/16-app-preloader-splash.md for the
// verified mapping — the odd-looking indices are inner cut-outs that must stay
// with their parent shape or evenodd fills them in.
const GROUPS = {
  'pm-pedal': [0, 2, 8, 9, 10, 11, 12, 13, 14, 15],
  'pm-fa': [1, 5],
  'pm-fb': [3, 6],
  'pm-fc': [4, 7],
}

const EXPECTED_SUBPATHS = 16

function buildLogoSvg() {
  const source = readFileSync(LOGO, 'utf8')

  const viewBox = source.match(/viewBox="([^"]+)"/)?.[1]
  const d = source.match(/\sd="([^"]+)"/)?.[1]
  if (!viewBox || !d) {
    throw new Error(`[preloader-logo] Could not read viewBox/path data from ${LOGO}`)
  }

  const subpaths = d
    .split(/(?=M )/)
    .map((s) => s.trim())
    .filter(Boolean)

  if (subpaths.length !== EXPECTED_SUBPATHS) {
    throw new Error(
      `[preloader-logo] Expected ${EXPECTED_SUBPATHS} subpaths but found ${subpaths.length}. ` +
        'The logo was re-exported — re-verify the group mapping in docs/16-app-preloader-splash.md ' +
        'before updating GROUPS.',
    )
  }

  const paths = Object.entries(GROUPS)
    .map(([id, indices]) => {
      const groupD = indices.map((i) => subpaths[i]).join(' ')
      const cls = id === 'pm-pedal' ? '' : ' class="pm-finger"'
      return `<path id="${id}"${cls} fill="#fff" fill-rule="evenodd" d="${groupD}"/>`
    })
    .join('')

  return `<svg id="pm-logo" viewBox="${viewBox}" aria-hidden="true"><g id="pm-grip">${paths}</g></svg>`
}

/**
 * Replaces the %PRELOADER_LOGO% placeholder in index.html with the logo split
 * into its animatable groups, so the source SVG stays the single source of
 * truth and no path data is hand-copied.
 */
export default function preloaderLogo() {
  return {
    name: 'pedalmonster-preloader-logo',
    transformIndexHtml: {
      order: 'pre',
      handler(html) {
        return html.replace('%PRELOADER_LOGO%', buildLogoSvg())
      },
    },
  }
}
