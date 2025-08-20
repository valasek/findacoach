class AddUsernameToUserProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :user_profiles, :username, :string
    add_index :user_profiles, :username, unique: true

    # Populate existing user profiles with usernames
    reversible do |dir|
      dir.up do
        UserProfile.find_each do |user_profile|
          user_profile.send(:generate_username)
          user_profile.save!(validate: false) # Skip validations for existing records
        end
      end
    end
  end
end
