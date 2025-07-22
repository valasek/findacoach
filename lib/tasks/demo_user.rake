namespace :demo_user do
  desc "Create a demo user data"
  task reset: :environment do
    begin
      if existing_demo_user = User.find_by(email: "demo@example.com")
        existing_demo_user.destroy
        puts "Existing demo user deleted."
      end
      demo_user = User.create!(
        email: "demo@example.com",
        password: "demo123",
        demo_user: true
      )
      DemoDataResetter.new(demo_user).reset!
      puts "Demo user created with email: #{demo_user.clients.count} clients and #{demo_user.sessions.count} sessions"
    rescue => e
      puts "Error creating demo user: #{e.message}"
    end
  end
end
