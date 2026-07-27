module Api
  class NotificationsController < BaseController
    def index
      notifications = Notification.where(user_id: current_profile.id).order(created_at: :desc)
      render json: notifications.map { |notification| serialize(notification) }
    end

    def read
      notification = Notification.find_by(id: params[:id], user_id: current_profile.id)
      return render json: { error: "Not found" }, status: :not_found unless notification

      notification.update(read_at: Time.current) if notification.unread?
      render json: serialize(notification)
    end

    private

    def serialize(notification)
      notification.as_json(only: [:id, :title, :body, :post_id, :group_id, :created_at])
                  .merge(unread: notification.unread?)
    end
  end
end
