class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.boolean :default, default: false, null: false

      t.timestamps
    end

    add_index :services, [ :user_id, :name ], unique: true
    add_index :services, :user_id, unique: true, where: '"default" = true', name: 'unique_default_service_per_user'
  end
end
