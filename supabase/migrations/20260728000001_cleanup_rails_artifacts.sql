-- The project's backend was originally built as a Ruby on Rails API (docs/18-backend-build-plan.md,
-- now superseded by docs/19-supabase-only-backend-plan.md). These tables are Rails/Active
-- Storage-specific bookkeeping with no place in the Supabase-only architecture — all empty,
-- confirmed before dropping.
drop table if exists active_storage_variant_records;
drop table if exists active_storage_attachments;
drop table if exists active_storage_blobs;
drop table if exists media_uploads;
drop table if exists ar_internal_metadata;
drop table if exists schema_migrations;
