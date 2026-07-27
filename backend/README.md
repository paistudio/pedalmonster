# Pedal Monster — Backend

Rails API backend. See `/docs/18-backend-build-plan.md` in the repo root for the full
architecture (Supabase Postgres, Supabase Auth, Active Storage on Supabase Storage) and
`/docs/02-data-model.md` for the entity/endpoint reference this implements.

## Local setup

Ruby 3.3.12 via rbenv (`.ruby-version` in this directory pins it), Postgres via local
build (no Homebrew on this machine — Ruby, libpq, and a full local Postgres server were all
compiled from source into `~/.rbenv`, `~/.postgresql`, `~/.libyaml`). If your machine already
has Homebrew, a normal `brew install postgresql libyaml` setup works fine too — nothing here
is source-build-specific beyond the toolchain itself.

```bash
# start local Postgres (dev/test only — production points at Supabase, see below)
pg_ctl -D ~/.postgresql-data -l ~/.postgresql-data/server.log -o "-k /tmp -p 5432" start

bundle install
bin/rails db:create db:migrate db:seed   # seeds the canonical city list
bundle exec rspec                        # full test suite
bin/rails server -p 3000
```

Copy `.env.example` to `.env` and fill in a dummy `SUPABASE_JWT_SECRET` for local manual
testing (the test suite uses its own fixed secret from `.env.test`, already committed since
it's not a real credential). Every endpoint requires a valid Supabase-signed JWT — see
`app/services/supabase_jwt_verifier.rb` and `spec/support/jwt_helpers.rb` for how to mint one
locally without a real Supabase project.

## Pointing at the real Supabase project

Fill in `DATABASE_URL`, `DATABASE_URL_MIGRATE`, `SUPABASE_JWT_SECRET` (or `SUPABASE_JWKS_URL`),
and the `SUPABASE_STORAGE_*` vars from the Supabase project dashboard — see `.env.example` for
the full list and `docs/18-backend-build-plan.md` for what each one is for. Development/test
keep using local Postgres regardless (see `config/database.yml`) — only `production` reads
`DATABASE_URL`.

## Why `auth.users` exists locally

`db/migrate/*_create_auth_users_stub_for_local_dev.rb` creates a minimal `auth.users` stand-in
only when Supabase's real one isn't already present — see that migration's comments. Local
dev/test seed/factory data creates rows in it (`Auth::User`, `app/models/auth/user.rb`) to
satisfy `profiles.id`'s foreign key; this never runs against the real Supabase database.
