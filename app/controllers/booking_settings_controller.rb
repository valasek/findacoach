class BookingSettingsController < ApplicationController
  before_action :authenticate_user!

  def update
    @booking_setting = current_user.booking_setting || current_user.build_booking_setting
    attributes = booking_setting_params.to_h.symbolize_keys
    duration_options_text = attributes.delete(:duration_options_text)
    weekly_hours = attributes.delete(:weekly_hours)
    disconnect_calendar = attributes.delete(:disconnect_calendar) == "1"
    attributes.delete(:ics_url) if attributes[:ics_url].blank?

    @booking_setting.assign_attributes(attributes)
    @booking_setting.duration_options_text = duration_options_text
    @booking_setting.weekly_hours = normalize_weekly_hours(weekly_hours)
    if disconnect_calendar
      @booking_setting.ics_url = nil
      @booking_setting.enabled = false
    end

    if @booking_setting.save
      CalendarRefreshJob.perform_later(@booking_setting.id) if @booking_setting.booking_ready?
      redirect_to edit_user_registration_path(tab: "booking"), notice: "Booking settings were saved."
    else
      redirect_to edit_user_registration_path(tab: "booking"), alert: @booking_setting.errors.full_messages.to_sentence
    end
  end

  private

  def booking_setting_params
    params.require(:booking_setting).permit(
      :enabled,
      :ics_url,
      :timezone,
      :duration_options_text,
      :default_duration,
      :minimum_notice_hours,
      :buffer_minutes,
      :disconnect_calendar,
      weekly_hours: {}
    )
  end

  def normalize_weekly_hours(raw_hours)
    raw_hours.to_h.each_with_object({}) do |(weekday, interval), result|
      start_time = interval["start"].to_s
      end_time = interval["end"].to_s
      next if start_time.blank? && end_time.blank?

      result[weekday] = [ { "start" => start_time, "end" => end_time } ]
    end
  end
end
