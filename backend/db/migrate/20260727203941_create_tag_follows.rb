class CreateTagFollows < ActiveRecord::Migration[8.1]
  # tag_name isn't a hard FK to a Tag table — see docs/02-data-model.md's Tag/TagFollow notes.
  def change
    create_table :tag_follows, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.string :tag_name, null: false
      t.datetime :created_at, null: false
    end

    add_foreign_key :tag_follows, :profiles, column: :user_id, on_delete: :cascade
    add_index :tag_follows, [:user_id, :tag_name], unique: true
  end
end
