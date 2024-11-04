class AddDemoUsertoUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :demo_user, :boolean, default: false
    add_index :users, :demo_user
  end
end
