# A DM-style conversation between exactly two users, keyed by the participant pair — see
# docs/02-data-model.md.
class ChatThread < ApplicationRecord
  belongs_to :user_one, class_name: "Profile", foreign_key: :user_one_id, inverse_of: false
  belongs_to :user_two, class_name: "Profile", foreign_key: :user_two_id, inverse_of: false
  has_many :chat_messages, dependent: :destroy
  has_many :chat_thread_reads, dependent: :destroy

  # Canonicalizes the pair (order doesn't matter to callers) and finds/creates the single
  # thread between them, matching the DB's ordered-pair check constraint.
  def self.between(profile_id_a, profile_id_b)
    ordered = [profile_id_a, profile_id_b].sort
    find_or_create_by!(user_one_id: ordered[0], user_two_id: ordered[1])
  end

  def self.find_between(profile_id_a, profile_id_b)
    ordered = [profile_id_a, profile_id_b].sort
    find_by(user_one_id: ordered[0], user_two_id: ordered[1])
  end

  def other_participant_id(profile_id)
    profile_id == user_one_id ? user_two_id : user_one_id
  end
end
