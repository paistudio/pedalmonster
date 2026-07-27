module Api
  class UsersController < BaseController
    def show
      profile = Profile.find(params[:id])
      render json: serialize(profile)
    end

    # Owner-only: username/bio/location/location_city_id/avatar_url only — never `email`,
    # that's Supabase-Auth-owned and edited directly from the frontend, see
    # docs/02-data-model.md's User entity notes.
    def update
      unless params[:id] == current_profile.id
        return render json: { error: "Forbidden" }, status: :forbidden
      end

      if current_profile.update(profile_params)
        render json: serialize(current_profile)
      else
        render json: { errors: current_profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Powers the drawer's Topics list, per docs/02-data-model.md — owner-only, same as #update.
    def followed_tags
      unless params[:id] == current_profile.id
        return render json: { error: "Forbidden" }, status: :forbidden
      end

      render json: TagFollow.where(user_id: current_profile.id).order(:tag_name).pluck(:tag_name)
    end

    private

    def profile_params
      params.permit(:username, :bio, :location, :location_city_id, :avatar_url)
    end

    def serialize(profile)
      profile.as_json(only: [:id, :username, :avatar_url, :bio, :location, :location_city_id, :points, :created_at])
             .merge(rank: profile.rank, email: Auth::User.find_by(id: profile.id)&.email)
    end
  end
end
