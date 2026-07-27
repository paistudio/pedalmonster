module Api
  class GroupsController < BaseController
    before_action :set_group, only: [:show, :update, :destroy, :join, :leave, :block]
    before_action :require_owner!, only: [:update, :destroy, :block]

    # ?mine=1 for "My Groups", omitted for "Discover" — see docs/10-groups.md's Groups List
    def index
      scope = params[:mine].present? ? current_profile.groups : Group.all
      render json: scope.order(:name).map { |group| serialize(group) }
    end

    def show
      render json: serialize(@group, include_members: true)
    end

    def create
      group = Group.new(group_params)
      group.created_by = current_profile.id

      if group.save
        group.group_memberships.create!(user_id: current_profile.id)
        render json: serialize(group), status: :created
      else
        render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @group.update(group_params)
        render json: serialize(@group)
      else
        render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @group.destroy
      head :no_content
    end

    # Silently no-ops for a blocked user rather than erroring, per docs/10-groups.md's Moderation.
    def join
      unless @group.blocked?(current_profile.id)
        @group.group_memberships.find_or_create_by(user_id: current_profile.id)
      end
      render json: { member_count: @group.reload.member_count }
    end

    def leave
      @group.group_memberships.where(user_id: current_profile.id).destroy_all
      render json: { member_count: @group.reload.member_count }
    end

    # Owner-only: removes the member's membership and adds them to blocked_user_ids so they
    # can't rejoin — scoped to this one group only, per docs/10-groups.md's Moderation.
    def block
      target_id = params.require(:user_id)
      @group.group_memberships.where(user_id: target_id).destroy_all
      @group.update!(blocked_user_ids: (@group.blocked_user_ids + [target_id]).uniq)
      render json: { member_count: @group.reload.member_count }
    end

    private

    def set_group
      @group = Group.find(params[:id])
    end

    def require_owner!
      return if @group.created_by == current_profile.id

      render json: { error: "Forbidden" }, status: :forbidden
    end

    def group_params
      params.permit(:name, :photo_url, :description, :location_city_id)
    end

    def serialize(group, include_members: false)
      json = group.as_json(only: [:id, :name, :photo_url, :description, :visibility,
                                   :member_count, :created_by, :location_city_id, :created_at])
      if include_members
        json["members"] = group.members.map { |m| { id: m.id, username: m.username, avatar_url: m.avatar_url } }
      end
      json
    end
  end
end
