import { reactive } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuth } from './useAuth'

// Threads are keyed by the OTHER participant's user id in local state — the chat room is a
// user-to-user conversation, not a per-listing room. A listing is only ever mentioned inside
// one via a `type=product` message, see sendProductMention.
const threadsByOtherUser = reactive({})

const { state: authState } = useAuth()

function pairIds(otherUserId) {
  return [authState.currentUser.id, otherUserId].sort()
}

// Mirrors the chat-send-message Edge Function's find-or-create logic (same sorted-pair lookup)
// so messages can be loaded before the first message is ever sent in a thread.
async function findThreadId(otherUserId) {
  const [userOneId, userTwoId] = pairIds(otherUserId)
  const { data } = await supabase
    .from('chat_threads')
    .select('id')
    .eq('user_one_id', userOneId)
    .eq('user_two_id', userTwoId)
    .maybeSingle()
  return data?.id ?? null
}

async function loadMessages(otherUserId) {
  const entry = threadsByOtherUser[otherUserId]
  const threadId = await findThreadId(otherUserId)
  entry.threadId = threadId
  if (!threadId) return

  const { data } = await supabase
    .from('chat_messages')
    .select('*')
    .eq('chat_thread_id', threadId)
    .order('created_at', { ascending: true })
  entry.messages.splice(0, entry.messages.length, ...(data || []))

  await supabase
    .from('chat_thread_reads')
    .upsert(
      { chat_thread_id: threadId, user_id: authState.currentUser.id, last_read_at: new Date().toISOString() },
      { onConflict: 'chat_thread_id,user_id' },
    )
}

export function useChatStore(otherUserId) {
  if (!threadsByOtherUser[otherUserId]) {
    threadsByOtherUser[otherUserId] = reactive({ threadId: null, messages: [], loaded: false })
    loadMessages(otherUserId).then(() => {
      threadsByOtherUser[otherUserId].loaded = true
    })
  }
  const entry = threadsByOtherUser[otherUserId]

  async function invokeSend(payload) {
    const { data, error } = await supabase.functions.invoke('chat-send-message', {
      body: { other_user_id: otherUserId, ...payload },
    })
    if (error) return
    entry.threadId = data.chat_thread_id
    entry.messages.push(data)
  }

  function sendMessage(body, media_urls = []) {
    const text = body.trim()
    if (!text && !media_urls.length) return
    invokeSend({ body: text, media_urls })
  }

  // Attaches a listing as a product-card message — called when the thread is opened via
  // a listing's "Chat Seller" CTA. Skipped if the same listing is already the most recent
  // message, so re-tapping "Chat Seller" on the same product doesn't spam duplicate cards.
  function sendProductMention(post) {
    const last = entry.messages[entry.messages.length - 1]
    if (last?.type === 'product' && last.listing_id === post.id) return
    invokeSend({ type: 'product', listing_id: post.id })
  }

  return { messages: entry.messages, sendMessage, sendProductMention }
}
