class AddDemoUsertoUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :demo_user, :boolean, default: false
    add_index :users, :demo_user
  end
end
