class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :client, null: false, foreign_key: true
      t.date :date
      t.decimal :duration, precision: 3, scale: 1
      t.boolean :paid, default: true
      t.boolean :group, default: false
      t.integer :group_size
      t.text :notes

      t.timestamps
    end
  end
end
