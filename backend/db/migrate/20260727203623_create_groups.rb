class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups, id: :uuid do |t|
      t.string :name, null: false
      t.string :photo_url
      t.text :description
      t.string :visibility, null: false, default: "public"
      t.uuid :created_by, null: false
      t.uuid :location_city_id
      t.uuid :blocked_user_ids, array: true, null: false, default: []
      t.integer :member_count, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :groups, :profiles, column: :created_by
    add_foreign_key :groups, :cities, column: :location_city_id
    add_index :groups, :created_by
  end
end
