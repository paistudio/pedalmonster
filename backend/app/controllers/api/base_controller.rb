module Api
  # Every real endpoint controller inherits from this — requires a valid Supabase JWT by
  # default (see Authenticatable). A controller that needs a public action should
  # `skip_before_action :authenticate_request!, only: [...]` explicitly, not inherit from
  # ApplicationController directly, so the exception is visible in the controller itself.
  class BaseController < ApplicationController
    include Authenticatable

    # API-only mode doesn't run the middleware that normally sets this for Active Storage's
    # Disk service URL generation (dev/test only — the production `supabase` S3 service
    # builds URLs directly from its endpoint config and doesn't need this).
    before_action do
      ActiveStorage::Current.url_options = { host: request.host, port: request.port, protocol: request.protocol }
    end
  end
end
