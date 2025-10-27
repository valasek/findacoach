class FindacoachController < ApplicationController
  before_action :authenticate_user!, only: [ :dashboard ]

  def index
    @total_users = User.all.count # for now lets count demo user as well
    # demo_users_hours = User.find_by(email: "demo@example.com").sessions.sum(:duration)
    @total_hours = Session.sum(:duration) # for now lets count demo_users_hours as well
    @demo_usage_count = ApplicationData.first_or_create(login_to_demo_count: 0).login_to_demo_count
  end

  def ai_coach
  end

  def coach_homepage
    @profile = UserProfile.find_by(username: params[:username])

    if @profile.nil?
      redirect_to root_path, alert: "Coach you are looking for was not found"
      return
    end
    render layout: "application_coach"
  end

  def increment_demo_count
    login_to_demo_count_record = ApplicationData.first_or_create(login_to_demo_count: 0)
    login_to_demo_count_record.increment!(:login_to_demo_count)
    puts "XXXXXXXX Incremented demo login count to #{login_to_demo_count_record.login_to_demo_count}"

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.action(:increment_complete, "") }
      format.json { render json: { status: "success", count: login_to_demo_count_record.login_to_demo_count } }
    end
  end

  def dashboard
    @clients_count = current_user.clients.count
    @hours_count = current_user.total_coaching_hours
    @sessions_paid = current_user.percentage_paid_seesions
    @sessions_count = current_user.sessions.count
    @coach_url = UserProfile.find_by(user: current_user)&.coach_url
  end

  def pricing
  end

  def changelog
    @changelog_entries = [
      {
        version: "0.5.0",
        date: "Oct 20, 2025",
        changes: {
          "New" => [
            "AI Coach added as an experiment"
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
        version: "0.4.0",
        date: "Aug 15, 2025",
        changes: {
          "New" => [
            "When registered, welcome email will be sent",
            "Sign in now supports Google SSO",
            "Home page for coaches and user settings",
            "Enter the demo account using one click"
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
