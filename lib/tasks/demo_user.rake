namespace :demo_user do
  desc "Reset demo user data"
  task reset: :environment do
    begin
      if existing_demo_user = User.find_by(email: "demo@example.com")
        existing_demo_user.destroy
        puts "Old demo user deleted sucessfully"
      end
      demo_user = User.create!(
        email: "demo@example.com",
        password: "demo123",
        demo_user: true
      )
      DemoDataResetter.new(demo_user).reset!
      puts "Demo user created sucessfully with #{demo_user.clients.count} clients and #{demo_user.sessions.count} sessions"
    rescue => e
        puts "Failed to refresh demo user: #{e.message}"
    end
  end
end
