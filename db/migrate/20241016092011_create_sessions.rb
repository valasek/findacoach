class CreateSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :sessions do |t|
      t.references :client, null: false, foreign_key: true
      t.date :date
      t.decimal :duration, precision: 3, scale: 1
      t.text :notes
      t.boolean :paid, default: true

      t.timestamps
    end
  end
end
