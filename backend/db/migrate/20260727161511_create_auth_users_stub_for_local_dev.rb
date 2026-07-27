class CreateAuthUsersStubForLocalDev < ActiveRecord::Migration[8.1]
  # In the real Supabase-hosted database, `auth.users` already exists (managed entirely by
  # Supabase Auth) and `profiles.id` is a FK into it — see docs/18-backend-build-plan.md.
  # Local dev/test Postgres has no such table, so this migration creates a minimal stand-in
  # ONLY when one isn't already present, so this migration is a no-op against the real Supabase
  # database (`to_regclass` finds the existing table and we skip immediately).
  def up
    return if auth_users_table_exists?

    execute "CREATE SCHEMA IF NOT EXISTS auth"
    create_table "auth.users", id: false do |t|
      t.uuid :id, primary_key: true, default: -> { "gen_random_uuid()" }
      t.string :email
      t.timestamps
    end
  end

  def down
    return unless auth_users_table_exists? && local_stub?

    drop_table "auth.users"
  end

  private

  def auth_users_table_exists?
    select_value("SELECT to_regclass('auth.users')").present?
  end

  # Only ever true for the stub we created ourselves — the real Supabase auth.users has many
  # more columns (encrypted_password, confirmed_at, etc.), this stub has exactly email + id.
  def local_stub?
    columns("auth.users").map(&:name).sort == %w[created_at email id updated_at]
  end
end
