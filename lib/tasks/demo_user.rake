namespace :demo_user do
  desc "Create a demo user data"
  task reset: :environment do
    begin
      if existing_demo_user = User.find_by(email: "demo@example.com")
        existing_demo_user.destroy
        puts "Existing demo user deleted"
      end
      demo_user = User.create!(
        email: "demo@example.com",
        password: "demo123",
        demo_user: true
      )
      demo_user.user_profile.update!(
        full_name: "Stanislav Valasek",
        phone: "421949888634",
        website: "https://www.stanislavvalasek.com/en/",
        bio: "Helping managers and team leaders to be more effective."
      )
      DemoDataResetter.new(demo_user).reset!
      def green(text) = "\e[32m#{text}\e[0m"
      puts <<~MSG
        Demo user created
          Email:    #{green demo_user.email}
          Clients:  #{green demo_user.clients.count}
          Services: #{green demo_user.services.count}
          Sessions: #{green demo_user.sessions.count}
          Hours:    #{green demo_user.sessions.sum(:duration)}
      MSG
    rescue => e
      puts "Error creating demo user: #{e.message}"
    end
  end
end
