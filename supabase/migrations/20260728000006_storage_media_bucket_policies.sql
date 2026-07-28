-- The `media` bucket was created via the dashboard with "public" read enabled, but a public
-- bucket only affects whether an anon SELECT can bypass RLS on already-known object paths —
-- storage.objects still has RLS enabled by default with no policies of its own, so every
-- INSERT from the browser (post/comment/chat/avatar photos) 403'd with "new row violates
-- row-level security policy" until now. See docs/19-supabase-only-backend-plan.md's Storage
-- section — no size/type validation yet, not blocking for MVP.
create policy "media bucket is publicly readable" on storage.objects for select
  using (bucket_id = 'media');

create policy "authenticated users can upload to media" on storage.objects for insert
  with check (bucket_id = 'media' and auth.role() = 'authenticated');

create policy "users can update their own media objects" on storage.objects for update
  using (bucket_id = 'media' and owner = auth.uid());

create policy "users can delete their own media objects" on storage.objects for delete
  using (bucket_id = 'media' and owner = auth.uid());
