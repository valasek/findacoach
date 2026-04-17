class AddServiceToSessions < ActiveRecord::Migration[8.1]
  def up
    # 1. Add the column (allow null initially)
    add_reference :sessions, :service, foreign_key: true

    # 2. Backfill: Create the default service for existing users and link sessions
    say_with_time "Backfilling services..." do
      # Use find_each to handle large datasets efficiently
      User.find_each do |user|
        # Create the default coaching service for the user
        # We use 'create!' to ensure it fails loudly if it violates your new indexes
        service = Service.create!(user: user, name: "Coaching", default: true)

        # Link all sessions belonging to this user's clients to the new service
        Session.joins(:client).where(clients: { user_id: user.id }).update_all(service_id: service.id)
      end
    end

    # 3. Now that every session has a service, enforce null: false
    change_column_null :sessions, :service_id, false
  end

  def down
    remove_reference :sessions, :service
  end
end
