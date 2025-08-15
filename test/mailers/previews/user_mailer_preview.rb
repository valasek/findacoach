class UserMailerPreview < ActionMailer::Preview
  # Preview all emails at http://localhost:3000/rails/mailers/user_mailer
  def welcome_email
    user = User.first
    UserMailer.welcome_email(user) || User.new(email: "demo@findacoach.eu")
  end
end
