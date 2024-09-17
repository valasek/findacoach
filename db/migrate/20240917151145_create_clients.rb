class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.string :company
      t.string :position
      t.integer :hours_ordered
      t.integer :hours_delivered
      t.text :coaching_goal
      t.boolean :archived

      t.timestamps
    end
  end
end
