module Auth
  # Maps to Supabase's auth.users table (or the local dev/test stub, see
  # db/migrate/*_create_auth_users_stub_for_local_dev.rb). The real Supabase table has many
  # more columns than this — this model is intentionally minimal and exists only so local
  # dev/test code (seeds, factories) has something to create the FK target for Profile#id.
  # Never referenced from real application logic — Rails does not own this table.
  class User < ApplicationRecord
    self.table_name = "auth.users"
  end
end
