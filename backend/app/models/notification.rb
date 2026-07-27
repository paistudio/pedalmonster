# See docs/02-data-model.md. @mention notifications aren't wired up yet — nothing creates
# those Notification rows in this pass, this model just supports the ones that do exist
# (comment replies, group joins) once their triggers are added.
class Notification < ApplicationRecord
  belongs_to :user, class_name: "Profile", foreign_key: :user_id, inverse_of: false
  belongs_to :post, optional: true
  belongs_to :group, optional: true

  def unread?
    read_at.nil?
  end
end
