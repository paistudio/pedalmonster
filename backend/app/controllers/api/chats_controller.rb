module Api
  # Threads are keyed by the other participant's user id (matching /chat/:userId in the
  # frontend), not by listing — see docs/02-data-model.md and docs/14-inbox-notifications-and-chat.md.
  class ChatsController < BaseController
    def index
      threads = ChatThread.where(user_one_id: current_profile.id).or(ChatThread.where(user_two_id: current_profile.id))
      render json: threads.map { |thread| serialize_thread(thread) }
    end

    def messages
      thread = ChatThread.find_between(current_profile.id, params[:user_id])
      return render json: [] unless thread

      render json: thread.chat_messages.order(:created_at).map { |m| serialize_message(m) }
    end

    def create_message
      thread = ChatThread.between(current_profile.id, params[:user_id])
      message = thread.chat_messages.build(message_params)
      message.sender_id = current_profile.id
      message.type ||= "text"

      if message.save
        render json: serialize_message(message), status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def read
      thread = ChatThread.between(current_profile.id, params[:user_id])
      record = ChatThreadRead.find_or_initialize_by(chat_thread: thread, user_id: current_profile.id)
      record.last_read_at = Time.current
      record.save!

      render json: { last_read_at: record.last_read_at }
    end

    private

    def message_params
      params.permit(:type, :body, media_urls: [])
    end

    def serialize_thread(thread)
      other_id = thread.other_participant_id(current_profile.id)
      last = thread.chat_messages.order(created_at: :desc).first
      read = ChatThreadRead.find_by(chat_thread: thread, user_id: current_profile.id)
      unread = last.present? && last.sender_id != current_profile.id &&
               (read.nil? || read.last_read_at.nil? || last.created_at > read.last_read_at)

      {
        other_user_id: other_id,
        last_message_preview: last&.body.presence || (last&.type == "product" ? "Sent a listing" : nil),
        last_message_at: last&.created_at,
        unread: unread
      }
    end

    def serialize_message(message)
      message.as_json(only: [:id, :chat_thread_id, :sender_id, :type, :body, :media_urls, :listing_id, :created_at])
    end
  end
end
