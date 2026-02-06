class FindacoachController < ApplicationController
  before_action :authenticate_user!, only: [ :dashboard ]

  def index
    @total_users = User.all.count # for now lets count demo user as well
    # demo_users_hours = User.find_by(email: "demo@example.com").sessions.sum(:duration)
    @total_sessions = Session.count() # for now lets count demo_users sessions as well
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
    @group_sessions_count = current_user.sessions.where(group: true).count
    @coach_url = UserProfile.find_by(user: current_user)&.coach_url
  end

  def pricing
  end

  def license
  end

  def changelog
    @changelog = Changelog.all
  end
end
