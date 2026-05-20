module UserObserver
  extend ActiveSupport::Concern

  included do
    after_create :send_welcome_email
  end

  private

  def send_welcome_email
    # OAuth users are auto-confirmed and skip the Devise confirmation email,
    # so send the welcome email now. Email/password users are not yet confirmed
    # and will receive the welcome email via after_confirmation instead.
    UserMailer.welcome_email(self).deliver_later if confirmed?
  end
end
