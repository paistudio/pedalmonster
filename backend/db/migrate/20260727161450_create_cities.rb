class CreateCities < ActiveRecord::Migration[8.1]
  def change
    create_table :cities, id: :uuid do |t|
      t.string :name, null: false
      t.string :province, null: false
      t.float :lat
      t.float :lng
    end

    add_index :cities, [:name, :province], unique: true
  end
end
