class BookingRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking_request, only: [ :show, :confirm, :decline ]

  def index
    @booking_requests = current_user.booking_requests.order(starts_at: :asc)
  end

  def show
  end

  def confirm
    if @booking_request.confirmed?
      return redirect_to @booking_request, notice: "This booking is already confirmed."
    end

    BookingRequestConfirmer.new(@booking_request).call(coach_message: decision_params[:coach_message])
    BookingMailer.confirmed_for_visitor(@booking_request).deliver_later
    BookingMailer.confirmed_for_coach(@booking_request).deliver_later
    redirect_to @booking_request, notice: "Session confirmed. The client was notified."
  rescue BookingRequestConfirmer::SlotUnavailable, BookingRequestConfirmer::DefaultServiceMissing => error
    redirect_to @booking_request, alert: error.message
  end

  def decline
    if @booking_request.declined?
      return redirect_to @booking_request, notice: "This booking is already declined."
    end
    unless @booking_request.pending?
      return redirect_to @booking_request, alert: "A confirmed booking cannot be declined here."
    end

    @booking_request.with_lock do
      @booking_request.update!(
        coach_message: decision_params[:coach_message],
        status: :declined,
        decided_at: Time.current
      )
    end
    BookingMailer.declined(@booking_request).deliver_later
    redirect_to @booking_request, notice: "Request declined. The client was notified."
  end

  private

  def set_booking_request
    @booking_request = current_user.booking_requests.find(params[:id])
  end

  def decision_params
    params.fetch(:booking_request, ActionController::Parameters.new).permit(:coach_message)
  end
end
