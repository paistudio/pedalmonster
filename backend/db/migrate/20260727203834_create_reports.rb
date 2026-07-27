class CreateReports < ActiveRecord::Migration[8.1]
  # Backs both the drawer's general "Report a problem" form (post_id null) and a per-post
  # "Report post" action (post_id set) — same entity, per docs/02-data-model.md.
  def change
    create_table :reports, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :post_id
      t.string :category, null: false
      t.text :description
      t.datetime :created_at, null: false
    end

    add_foreign_key :reports, :profiles, column: :user_id
    add_foreign_key :reports, :posts, column: :post_id
    add_index :reports, :user_id
  end
end
