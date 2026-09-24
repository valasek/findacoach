class BookingMailer < ApplicationMailer
  def request_received(booking_request)
    @booking_request = booking_request
    @coach = booking_request.user

    mail(
      to: booking_request.visitor_email,
      subject: "Your booking request with #{@coach.user_profile.display_name}"
    )
  end

  def new_request(booking_request)
    @booking_request = booking_request
    @coach = booking_request.user

    mail(
      to: @coach.email,
      subject: "New booking request from #{booking_request.visitor_name}"
    )
  end

  def confirmed_for_visitor(booking_request)
    prepare_confirmation(booking_request)
    mail(
      to: booking_request.visitor_email,
      subject: "Session confirmed with #{@coach.user_profile.display_name}"
    )
  end

  def confirmed_for_coach(booking_request)
    prepare_confirmation(booking_request)
    mail(
      to: @coach.email,
      subject: "Session confirmed with #{booking_request.visitor_name}"
    )
  end

  def declined(booking_request)
    @booking_request = booking_request
    @coach = booking_request.user

    mail(
      to: booking_request.visitor_email,
      subject: "Update on your session request"
    )
  end

  private

  def prepare_confirmation(booking_request)
    @booking_request = booking_request
    @coach = booking_request.user
    attachments["coaching-session.ics"] = {
      mime_type: "text/calendar",
      content: calendar_for(booking_request)
    }
  end

  def calendar_for(booking_request)
    calendar = Icalendar::Calendar.new
    calendar.prodid = "-//Find a Coach//Session Booking//EN"
    calendar.publish
    calendar.event do |event|
      event.dtstart = calendar_time(booking_request.starts_at)
      event.dtend = calendar_time(booking_request.starts_at + booking_request.duration_minutes.minutes)
      event.dtstamp = calendar_time(booking_request.decided_at || Time.current)
      event.uid = "booking-request-#{booking_request.id}@findacoach.eu"
      event.summary = "Coaching session with #{booking_request.user.user_profile.display_name}"
    end
    calendar.to_ical
  end

  def calendar_time(time)
    Icalendar::Values::DateTime.new(time.utc, "tzid" => "UTC")
  end
end
