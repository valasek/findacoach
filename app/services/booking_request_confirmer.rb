class BookingRequestConfirmer
  class SlotUnavailable < StandardError; end
  class DefaultServiceMissing < StandardError; end

  def initialize(booking_request)
    @booking_request = booking_request
  end

  def call(coach_message: nil)
    setting = @booking_request.user.booking_setting
    raise SlotUnavailable, "Booking is not configured" unless setting&.booking_ready?

    setting.with_lock do
      @booking_request.lock!
      return @booking_request if @booking_request.confirmed?
      raise SlotUnavailable, "This request has already been decided" unless @booking_request.pending?

      verify_slot!(setting)
      service = @booking_request.user.services.find_by(default: true)
      raise DefaultServiceMissing, "Set a default service before confirming bookings" unless service

      client = find_or_create_client!
      session = client.sessions.create!(
        service:,
        starts_at: @booking_request.starts_at,
        date: @booking_request.starts_at.in_time_zone(setting.timezone).to_date,
        duration: @booking_request.duration_minutes / 60.0,
        paid: true,
        group: false,
        notes: @booking_request.goal
      )
      @booking_request.update!(
        client:,
        session:,
        coach_message:,
        status: :confirmed,
        decided_at: Time.current
      )
    end

    @booking_request
  end

  private

  def verify_slot!(setting)
    available = AvailableSlotFinder.new(setting).free?(
      starts_at: @booking_request.starts_at,
      duration_minutes: @booking_request.duration_minutes
    )
    raise SlotUnavailable, "This time is no longer available" unless available
  rescue CalendarBusyIntervals::Unavailable
    raise SlotUnavailable, "Calendar availability could not be verified"
  end

  def find_or_create_client!
    client = @booking_request.user.clients.find_or_initialize_by(email: @booking_request.visitor_email)
    client.name = @booking_request.visitor_name if client.new_record?
    client.save!
    client
  end
end
