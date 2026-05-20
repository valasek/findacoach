# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # After a successful email confirmation, sign the user in immediately and
  # send them to the dashboard rather than dumping them on the sign-in page.
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      sign_in(resource)
      set_flash_message!(:notice, :confirmed)
      redirect_to findacoach_dashboard_path
    else
      render :new
    end
  end
end
