class CreateProfiles < ActiveRecord::Migration[8.1]
  # This is the `User` entity from docs/02-data-model.md minus auth credentials — id is a FK
  # to Supabase's auth.users.id (or the local stub, see the previous migration), not a
  # Rails-generated default. `rank` isn't a column — it's derived from `points`, computed on
  # the model, matching docs/03-auth-user-profile.md's "Rank is derived, not stored independently".
  def change
    create_table :profiles, id: false do |t|
      t.uuid :id, primary_key: true, null: false
      t.string :username, null: false
      t.string :avatar_url
      t.string :bio
      t.string :location
      t.uuid :location_city_id
      t.integer :points, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :profiles, "auth.users", column: :id, primary_key: :id, on_delete: :cascade
    add_foreign_key :profiles, :cities, column: :location_city_id
    add_index :profiles, :username, unique: true
  end
end
