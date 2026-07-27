import { reactive } from 'vue'
import { currentUser } from '../mocks'

// Not part of docs/02-data-model.md (no Message/Chat entity defined there yet) —
// client-only thread state to satisfy docs/07-marketplace.md's chat requirement in Phase 1.
// Threads are keyed by the OTHER participant's user id — the chat room is a user-to-user
// conversation, not a per-listing room. A listing is only ever attached as a message inside it.
const threads = reactive({})

const CANNED_REPLIES = [
  'Halo, masih ada kak.',
  'Boleh nego dikit, langsung aja chat ya.',
  'Siap, bisa COD atau kirim.',
]

export function useChatStore(otherUserId) {
  if (!threads[otherUserId]) {
    threads[otherUserId] = []
  }
  const messages = threads[otherUserId]

  function replyFromOther(reply) {
    if (!otherUserId || otherUserId === currentUser.id) return
    setTimeout(() => {
      messages.push({
        id: `m-${Date.now()}-r`,
        type: 'text',
        sender_id: otherUserId,
        body: reply,
        created_at: new Date().toISOString(),
      })
    }, 900)
  }

  function sendMessage(body, media_urls = []) {
    const text = body.trim()
    if (!text && !media_urls.length) return
    messages.push({
      id: `m-${Date.now()}`,
      type: 'text',
      sender_id: currentUser.id,
      body: text,
      media_urls,
      created_at: new Date().toISOString(),
    })
    replyFromOther(CANNED_REPLIES[Math.floor(Math.random() * CANNED_REPLIES.length)])
  }

  // Attaches a listing as a product-card message — called when the thread is opened via
  // a listing's "Chat Seller" CTA. Skipped if the same listing is already the most recent
  // message, so re-tapping "Chat Seller" on the same product doesn't spam duplicate cards.
  function sendProductMention(post) {
    const last = messages[messages.length - 1]
    if (last?.type === 'product' && last.listing.id === post.id) return

    messages.push({
      id: `m-${Date.now()}-product`,
      type: 'product',
      sender_id: currentUser.id,
      listing: {
        id: post.id,
        title: post.title,
        price: post.type_data.price,
        image: post.media_urls[0] || null,
      },
      created_at: new Date().toISOString(),
    })
    replyFromOther('Halo, boleh tanya-tanya soal ini.')
  }

  return { messages, sendMessage, sendProductMention }
}
