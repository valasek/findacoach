module UserObserver
  extend ActiveSupport::Concern

  included do
    after_create :send_welcome_email
  end

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
