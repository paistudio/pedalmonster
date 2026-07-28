<script setup>
import { computed, watch } from 'vue'
import BottomSheet from './BottomSheet.vue'
import CommentList from './CommentList.vue'
import CommentComposer from './CommentComposer.vue'
import { useCommentStore } from '../composables/useCommentStore'

const props = defineProps({
  open: { type: Boolean, required: true },
  post: { type: Object, default: null },
})
const emit = defineEmits(['close'])

const commentStore = useCommentStore()
const comments = computed(() =>
  props.post ? commentStore.getCommentsForPost(props.post.id) : [],
)

watch(
  () => [props.open, props.post?.id],
  ([open, postId]) => {
    if (open && postId) commentStore.loadComments(postId)
  },
  { immediate: true },
)

function submitComment({ body, media_urls }) {
  if (!props.post) return
  commentStore.addComment(props.post, body, media_urls)
}
</script>

<template>
  <BottomSheet :open="open" @close="$emit('close')">
    <h2 class="sheet-title">{{ comments.length }} Comments</h2>
    <div class="sheet-scroll">
      <CommentList v-if="post" :comments="comments" />
    </div>
    <CommentComposer allow-attachments @submit="submitComment" />
  </BottomSheet>
</template>

<style scoped>
.sheet-title {
  font-size: 16px;
  margin: 0 0 12px;
  text-align: center;
}

.sheet-scroll {
  max-height: 50vh;
  overflow-y: auto;
  margin: 0 -4px 4px;
  padding: 0 4px;
}
</style>
