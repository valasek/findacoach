class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @login_url  = root_url
    @contact_url = "https://www.stanislavvalasek.com/en/contact/"
    @form_url = "https://forms.gle/ctWfVaMc9qVmeb4N9"

    mail(
      to: @user.email,
      subject: "Welcome to Find a Coach"
    )
  end
end
