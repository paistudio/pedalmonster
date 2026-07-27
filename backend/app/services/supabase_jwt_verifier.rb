require "jwt"
require "open-uri"
require "json"

# Verifies a Supabase Auth-issued JWT. Rails never issues its own tokens — see
# docs/18-backend-build-plan.md. Supports either of Supabase's two signing schemes,
# whichever ends up configured on the project:
#   - SUPABASE_JWT_SECRET: legacy shared-secret HS256 signing
#   - SUPABASE_JWKS_URL: newer rotating-key JWKS-based signing (RS256/ES256)
class SupabaseJwtVerifier
  class InvalidToken < StandardError; end

  class << self
    # Returns the decoded payload (a Hash) on success; raises InvalidToken on any failure.
    def decode(token)
      raise InvalidToken, "blank token" if token.blank?

      if ENV["SUPABASE_JWT_SECRET"].present?
        decode_with_secret(token)
      elsif ENV["SUPABASE_JWKS_URL"].present?
        decode_with_jwks(token)
      else
        raise InvalidToken, "no Supabase JWT verification key configured (set SUPABASE_JWT_SECRET or SUPABASE_JWKS_URL)"
      end
    rescue JWT::DecodeError => e
      raise InvalidToken, e.message
    end

    private

    def decode_with_secret(token)
      payload, = JWT.decode(token, ENV.fetch("SUPABASE_JWT_SECRET"), true, algorithm: "HS256")
      payload
    end

    def decode_with_jwks(token)
      jwks = JWT::JWK::Set.new(fetch_jwks)
      payload, = JWT.decode(token, nil, true, algorithms: %w[RS256 ES256], jwks: jwks)
      payload
    end

    # Cached for an hour so we're not hitting Supabase's JWKS endpoint on every request.
    def fetch_jwks
      @jwks_fetched_at ||= Time.at(0)
      if @jwks_cache.nil? || Time.now - @jwks_fetched_at > 1.hour
        @jwks_cache = JSON.parse(URI.parse(ENV.fetch("SUPABASE_JWKS_URL")).open.read)
        @jwks_fetched_at = Time.now
      end
      @jwks_cache
    end
  end
end
