class CalendarRefreshJob < ApplicationJob
  queue_as :default

  def perform(booking_setting_id)
    setting = BookingSetting.find_by(id: booking_setting_id)
    return unless setting&.booking_ready?

    CalendarBusyIntervals.new(setting).call(
      window_start: Time.current.utc,
      window_end: 15.days.from_now.utc
    )
  rescue CalendarBusyIntervals::Unavailable
    nil
  end
end
