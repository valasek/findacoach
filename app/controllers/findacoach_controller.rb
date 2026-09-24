class FindacoachController < ApplicationController
  before_action :authenticate_user!, only: [ :dashboard ]

  def index
    @total_users = User.all.count # for now lets count demo user as well
    @total_services = Service.group(:name).count.keys.count # for now lets count demo services as well
    @total_sessions = Session.count() # for now lets count demo_users sessions as well
    @total_hours = Session.sum(:duration) # for now lets count demo_users_hours as well
    @demo_usage_count = ApplicationData.first_or_create(login_to_demo_count: 0).login_to_demo_count
  end

  def coach_homepage
    @profile = UserProfile.find_by(username: params[:username])

    if @profile.nil?
      redirect_to root_path, alert: "Coach you are looking for was not found"
      return
    end

    @coach = @profile.user
    @booking_setting = @coach.booking_setting
    load_booking_form if @booking_setting&.booking_ready?

    render layout: "application_coach"
  end

  def increment_demo_count
    login_to_demo_count_record = ApplicationData.first_or_create(login_to_demo_count: 0)
    login_to_demo_count_record.increment!(:login_to_demo_count)

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
    @hours_per_service = get_hours_per_service(current_user)
    @coach_url = UserProfile.find_by(user: current_user)&.coach_url
  end

  def pricing
  end

  def license
  end

  def changelog
    @changelog = Changelog.all
  end

  private

  def load_booking_form
    @booking_request = @coach.booking_requests.build(
      duration_minutes: selected_booking_duration,
      visitor_timezone: selected_booking_timezone,
      idempotency_key: SecureRandom.uuid
    )
    @slots = AvailableSlotFinder.new(@booking_setting).call(
      duration_minutes: @booking_request.duration_minutes,
      visitor_timezone: @booking_request.visitor_timezone
    )
  rescue CalendarBusyIntervals::Unavailable
    @slots = []
    @availability_error = "The coach's calendar is temporarily unavailable. Please try again later."
  end

  def selected_booking_duration
    duration = params[:duration].presence&.to_i || @booking_setting.default_duration
    @booking_setting.duration_options.include?(duration) ? duration : @booking_setting.default_duration
  end

  def selected_booking_timezone
    timezone = params[:timezone].presence || "UTC"
    ActiveSupport::TimeZone[timezone] ? timezone : "UTC"
  end

  def get_hours_per_service(user)
    if user.services.count > 1
      user.services.map do |service|
        hours = user.sessions.where(service: service).sum(:duration)
        "#{hours} hours #{service.name}"
      end.join(", ")
    else
      ""
    end
  end
end
