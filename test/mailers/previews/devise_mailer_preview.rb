class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = User.first
    token = user.send(:reset_password_token)
    Devise::Mailer.reset_password_instructions(user, token)
  end
end
