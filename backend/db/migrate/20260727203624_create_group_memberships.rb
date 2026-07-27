class CreateGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :group_memberships, id: :uuid do |t|
      t.uuid :group_id, null: false
      t.uuid :user_id, null: false
      t.datetime :joined_at, null: false
    end

    add_foreign_key :group_memberships, :groups, column: :group_id, on_delete: :cascade
    add_foreign_key :group_memberships, :profiles, column: :user_id, on_delete: :cascade
    add_index :group_memberships, [:group_id, :user_id], unique: true
  end
end
