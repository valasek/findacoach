class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name
      t.string :website
      t.text :bio

      t.timestamps
    end
  end
end
