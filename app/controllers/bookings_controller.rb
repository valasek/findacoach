class BookingsController < ApplicationController
  layout "application_coach"

  before_action :set_coach
  before_action :ensure_booking_ready, except: :received
  before_action :reject_honeypot, only: :create

  def new
    redirect_to coach_homepage_path(
      username: @profile.username,
      duration: params[:duration],
      timezone: params[:timezone]
    )
  end

  def create
    existing_request = @coach.booking_requests.find_by(idempotency_key: booking_request_params[:idempotency_key])
    return redirect_to received_coach_bookings_path(username: @profile.username) if existing_request

    @booking_request = @coach.booking_requests.build(booking_request_params)
    validate_selected_slot

    if @booking_request.errors.empty? && @booking_request.save
      BookingMailer.request_received(@booking_request).deliver_later
      BookingMailer.new_request(@booking_request).deliver_later
      redirect_to received_coach_bookings_path(username: @profile.username)
    else
      load_slots
      render "findacoach/coach_homepage", status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to received_coach_bookings_path(username: @profile.username)
  end

  def received
  end

  private

  def set_coach
    @profile = UserProfile.find_by!(username: params[:username])
    @coach = @profile.user
    @booking_setting = @coach.booking_setting
  end

  def ensure_booking_ready
    return if @booking_setting&.booking_ready?

    redirect_to coach_homepage_path(username: @profile.username), alert: "Online booking is not available for this coach."
  end

  def reject_honeypot
    redirect_to received_coach_bookings_path(username: @profile.username) if params[:website_url].present?
  end

  def load_slots
    @slots = AvailableSlotFinder.new(@booking_setting).call(
      duration_minutes: @booking_request.duration_minutes,
      visitor_timezone: @booking_request.visitor_timezone
    )
  rescue CalendarBusyIntervals::Unavailable
    @slots = []
    @availability_error = "The coach's calendar is temporarily unavailable. Please try again later."
  end

  def validate_selected_slot
    unless @booking_setting.duration_options.include?(@booking_request.duration_minutes)
      @booking_request.errors.add(:duration_minutes, "is not offered")
      return
    end

    slots = AvailableSlotFinder.new(@booking_setting).call(
      duration_minutes: @booking_request.duration_minutes,
      visitor_timezone: @booking_request.visitor_timezone
    )
    selected = slots.any? { |slot| slot.starts_at.to_i == @booking_request.starts_at&.to_i }
    @booking_request.errors.add(:starts_at, "is no longer available") unless selected
  rescue CalendarBusyIntervals::Unavailable, ArgumentError
    @booking_request.errors.add(:starts_at, "could not be verified")
  end

  def booking_request_params
    permitted = params.require(:booking_request).permit(
      :visitor_name,
      :visitor_email,
      :goal,
      :starts_at,
      :visitor_timezone,
      :duration_minutes,
      :idempotency_key
    )
    permitted[:starts_at] = Time.iso8601(permitted[:starts_at]) if permitted[:starts_at].present?
    permitted
  rescue ArgumentError
    permitted[:starts_at] = nil
    permitted
  end
end
