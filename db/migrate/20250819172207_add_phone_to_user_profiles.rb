class AddPhoneToUserProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :user_profiles, :phone, :string
  end
end
