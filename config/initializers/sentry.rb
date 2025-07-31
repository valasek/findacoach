# frozen_string_literal: true

return if Rails.env.development? || Rails.env.test?

APP_VERSION = File.read(Rails.root.join("VERSION")).strip rescue "0.0.0"
RELEASE_VERSION = "#{Rails.application.class.module_parent_name.downcase}@#{APP_VERSION}"

Sentry.init do |config|
  config.dsn = 'https://e875316bfe48264ec86904367bc593c7@o417369.ingest.us.sentry.io/4508238497382400' # rubocop:disable Style/StringLiterals
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for tracing.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # Set profiles_sample_rate to profile 100%
  # of sampled transactions.
  # We recommend adjusting this value in production.
  config.profiles_sample_rate = 1.0
  config.release = RELEASE_VERSION
end
