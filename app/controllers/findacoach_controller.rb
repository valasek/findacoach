class FindacoachController < ApplicationController
  before_action :authenticate_user!, only: [ :admin, :dashboard ]

  def index
    @total_users = User.all.count # for now lets count demo user as well
    # demo_users_hours = User.find_by(email: "demo@example.com").sessions.sum(:duration)
    @total_hours = Session.sum(:duration) # for now lets count demo_users_hours as well
  end

  def admin
    @users = User.all
  end

  def dashboard
    @clients_count = current_user.clients.count
    @hours_count = current_user.total_coaching_hours
    @sessions_paid = current_user.percentage_paid_seesions
    @sessions_count = current_user.sessions.count
  end

  def changelog
    @changelog_entries = [
      {
        version: "0.4.0",
        date: "Aug 15, 2025",
        changes: {
          "New" => [
            "Welcome email after new registration"
          ],
          "Changed" => [
            "Upgrade the system to the latest and more secure packages"
          ]
          # "Fixed" => [
          #   "",
          #   ""
          # ]
        }
      },
      {
        version: "0.3.0",
        date: "Jul 23, 2025",
        changes: {
          "New" => [
            "Full demo version available"
          ],
          "Changed" => [
            "Upgrade the underlying technology to Rails 8.0.2"
          ]
          # "Fixed" => [
          #   "",
          #   ""
          # ]
        }
      },
      {
        version: "0.2.0",
        date: "October 31, 2024",
        changes: {
          "New" => [
            "Export to MS Excel, compliant with ICF requirements",
            "Security hardening and new security section on home page"
          ],
          "Changed" => [
            "New statistics to the dashboard"
          ]
          # "Fixed" => [
          #   "",
          #   ""
          # ]
        }
      },
      {
        version: "0.1.0",
        date: "October 23, 2024",
        changes: {
          "New" => [
            "Find a Coach - alpha version. First release to gather initial feedback",
            "Available for all users without any restrictions",
            "User can manage clients and coaching hours per client"
          ]
          # "Changed" => [
          #   "...",
          #   ""
          # ],
          # "Fixed" => [
          #   "",
          #   ""
          # ]
        }
      }
    ]
  end
end
