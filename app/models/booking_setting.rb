class BookingSetting < ApplicationRecord
  ALLOWED_CALENDAR_HOST_SUFFIXES = %w[
    google.com googleusercontent.com live.com outlook.com office.com office365.com
  ].freeze
  DEFAULT_WEEKLY_HOURS = {
    "1" => [ { "start" => "09:00", "end" => "17:00" } ],
    "2" => [ { "start" => "09:00", "end" => "17:00" } ],
    "3" => [ { "start" => "09:00", "end" => "17:00" } ],
    "4" => [ { "start" => "09:00", "end" => "17:00" } ],
    "5" => [ { "start" => "09:00", "end" => "17:00" } ]
  }.freeze

  belongs_to :user

  encrypts :ics_url

  validates :timezone, presence: true
  validates :default_duration, inclusion: { in: 15..180 }
  validates :minimum_notice_hours, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 336 }
  validates :buffer_minutes, inclusion: { in: [ 0, 15, 30, 45, 60 ] }
  validate :timezone_exists
  validate :duration_options_are_valid
  validate :weekly_hours_are_valid
  validate :calendar_url_is_supported

  before_validation :set_default_weekly_hours, on: :create

  def booking_ready?
    enabled? && ics_url.present? && weekly_hours.values.flatten.any?
  end

  def duration_options_text
    Array(duration_options).join(", ")
  end

  def duration_options_text=(value)
    self.duration_options = value.to_s.split(",").filter_map { |duration| Integer(duration.strip, exception: false) }
  end

  private

  def set_default_weekly_hours
    self.weekly_hours = DEFAULT_WEEKLY_HOURS if weekly_hours.blank?
  end

  def timezone_exists
    TZInfo::Timezone.get(timezone) if timezone.present?
  rescue TZInfo::InvalidTimezoneIdentifier
    errors.add(:timezone, "is not valid")
  end

  def duration_options_are_valid
    options = Array(duration_options).filter_map { |duration| Integer(duration, exception: false) }

    if options.empty? || options.length > 6 || options.uniq.length != options.length || options.any? { |duration| !duration.between?(15, 180) || (duration % 15).nonzero? }
      errors.add(:duration_options, "must contain one to six unique 15-minute increments between 15 and 180")
    elsif !options.include?(default_duration)
      errors.add(:default_duration, "must be one of the offered durations")
    else
      self.duration_options = options.sort
    end
  end

  def weekly_hours_are_valid
    return errors.add(:weekly_hours, "must include at least one working interval") unless weekly_hours.is_a?(Hash) && weekly_hours.values.flatten.any?

    weekly_hours.each do |weekday, intervals|
      unless weekday.to_s.match?(/\A[0-6]\z/) && valid_intervals?(intervals)
        errors.add(:weekly_hours, "contains an invalid or overlapping interval")
        break
      end
    end
  end

  def valid_intervals?(intervals)
    parsed = Array(intervals).filter_map do |interval|
      next unless interval.is_a?(Hash)

      start_minute = minute_of_day(interval["start"] || interval[:start])
      end_minute = minute_of_day(interval["end"] || interval[:end])
      [ start_minute, end_minute ] if start_minute && end_minute && start_minute < end_minute
    end

    return false unless parsed.length == Array(intervals).length

    parsed.sort_by(&:first).each_cons(2).none? { |current, following| current.last > following.first }
  end

  def minute_of_day(value)
    match = value.to_s.match(/\A([01]\d|2[0-3]):([0-5]\d)\z/)
    match && (match[1].to_i * 60) + match[2].to_i
  end

  def calendar_url_is_supported
    return if ics_url.blank?

    uri = URI.parse(ics_url)
    host = uri.host.to_s.downcase
    supported_host = ALLOWED_CALENDAR_HOST_SUFFIXES.any? { |suffix| host == suffix || host.end_with?(".#{suffix}") }
    errors.add(:ics_url, "must be a private Google or Outlook HTTPS calendar URL") unless uri.scheme == "https" && supported_host
  rescue URI::InvalidURIError
    errors.add(:ics_url, "must be a valid URL")
  end
end
