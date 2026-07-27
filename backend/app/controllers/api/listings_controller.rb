module Api
  # GET /api/listings — dedicated filtered browse endpoint over Post rows where type=listing,
  # per docs/02-data-model.md and docs/07-marketplace.md's filter sheet (category, condition,
  # location, sort). "Nearest first" sort isn't implemented here yet — it needs the viewer's
  # resolved location (docs/17-regional-location.md) which wasn't in the Phase 2 build order.
  class ListingsController < BaseController
    def index
      scope = Post.where(type: "listing")
      scope = scope.where("type_data ->> 'category' = ?", params[:category]) if params[:category].present?
      scope = scope.where("type_data ->> 'condition' = ?", params[:condition]) if params[:condition].present?
      scope = scope.where(location_city_id: params[:location_city_id]) if params[:location_city_id].present?
      scope = apply_sort(scope)

      render json: scope.map { |post| PostSerializer.call(post) }
    end

    private

    def apply_sort(scope)
      case params[:sort]
      when "price_asc"
        scope.order(Arel.sql("(type_data ->> 'price')::integer ASC"))
      when "price_desc"
        scope.order(Arel.sql("(type_data ->> 'price')::integer DESC"))
      else
        scope.order(created_at: :desc)
      end
    end
  end
end
