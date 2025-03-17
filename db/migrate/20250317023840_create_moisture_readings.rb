class CreateMoistureReadings < ActiveRecord::Migration[8.0]
  def change
    create_table :moisture_readings do |t|
      t.references :plant, null: false, foreign_key: true
      t.integer :moisture_level, null: false
      t.datetime :recorded_at, null: false

      t.timestamps
    end
    add_index :moisture_readings, :recorded_at
  end
end
