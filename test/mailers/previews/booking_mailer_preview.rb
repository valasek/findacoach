class BookingMailerPreview < ActionMailer::Preview
  def request_received
    BookingMailer.request_received(booking_request)
  end

  def new_request
    BookingMailer.new_request(booking_request)
  end

  def confirmed_for_visitor
    BookingMailer.confirmed_for_visitor(confirmed_booking_request)
  end

  def confirmed_for_coach
    BookingMailer.confirmed_for_coach(confirmed_booking_request)
  end

  def declined
    BookingMailer.declined(declined_booking_request)
  end

  private

  def booking_request
    BookingRequest.includes(user: :user_profile).order(created_at: :desc).first || sample_booking_request
  end

  def confirmed_booking_request
    booking_request.tap do |request|
      request.assign_attributes(status: :confirmed, decided_at: Time.current)
    end
  end

  def declined_booking_request
    booking_request.tap do |request|
      request.assign_attributes(
        status: :declined,
        coach_message: request.coach_message.presence || "Thank you for your request. Please choose another time.",
        decided_at: Time.current
      )
    end
  end

  def sample_booking_request
    coach = User.includes(:user_profile).first || sample_coach
    BookingRequest.new(
      id: 1,
      user: coach,
      visitor_name: "Alex Example",
      visitor_email: "alex@example.com",
      goal: "Prepare for a promotion",
      starts_at: 2.days.from_now.change(min: 0),
      visitor_timezone: "UTC",
      duration_minutes: 60
    )
  end

  def sample_coach
    User.new(email: "coach@example.com").tap do |coach|
      coach.build_user_profile(full_name: "Demo Coach", username: "demo-coach")
    end
  end
end
