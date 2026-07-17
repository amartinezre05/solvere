class CreateUvrValues < ActiveRecord::Migration[8.1]
  def change
    create_table :uvr_values do |t|
      t.date :date, null: false
      t.decimal :value, precision: 12, scale: 4, null: false

      t.timestamps
    end
    add_index :uvr_values, :date, unique: true
  end
end
