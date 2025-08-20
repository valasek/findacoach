class Application < ActiveRecord::Migration[8.0]
  def change
    create_table :application_data do |t|
      t.integer :login_to_demo_count, default: 0, null: false

      t.timestamps
    end
  end
end
