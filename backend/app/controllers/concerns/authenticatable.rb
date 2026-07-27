# Verifies the Supabase-issued JWT on every request and resolves it to a Profile — Rails
# never issues its own auth tokens, see docs/18-backend-build-plan.md. Included by
# Api::BaseController so it applies to every API endpoint unless explicitly skipped.
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    token = bearer_token
    return render_unauthorized("Missing token") if token.blank?

    payload = SupabaseJwtVerifier.decode(token)
    @current_profile = Profile.find_by(id: payload["sub"])
    render_unauthorized("Unknown profile") unless @current_profile
  rescue SupabaseJwtVerifier::InvalidToken => e
    render_unauthorized(e.message)
  end

  def bearer_token
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")

    header.delete_prefix("Bearer ")
  end

  def current_profile
    @current_profile
  end

  def render_unauthorized(reason)
    render json: { error: "Unauthorized", reason: reason }, status: :unauthorized
  end
end
