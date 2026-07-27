# Mints a fake-but-validly-signed Supabase JWT for a given profile, using the fixed dummy
# SUPABASE_JWT_SECRET from .env.test (see docs/18-backend-build-plan.md's Testing section —
# no network calls to a real Supabase Auth in the fast path).
module JwtHelpers
  def auth_headers_for(profile)
    payload = { sub: profile.id, exp: 1.hour.from_now.to_i }
    token = JWT.encode(payload, ENV.fetch("SUPABASE_JWT_SECRET"), "HS256")
    { "Authorization" => "Bearer #{token}" }
  end
end
