module ApplicationHelper
  def iana_time_zone_options
    ([ [ "UTC", "UTC" ] ] + ActiveSupport::TimeZone.all.map { |zone| [ zone.to_s, zone.tzinfo.identifier ] })
      .uniq { |(_label, identifier)| identifier }
  end
end
