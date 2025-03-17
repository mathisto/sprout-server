class CreatePlants < ActiveRecord::Migration[8.0]
  def change
    create_table :plants do |t|
      t.string :slug
      t.string :species
      t.string :location
      t.integer :preferred_moisture_min
      t.integer :preferred_moisture_max
      t.text :care_notes

      t.timestamps
    end
    add_index :plants, :slug, unique: true
  end
end
