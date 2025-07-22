class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_in_path_for(resource)
    findacoach_dashboard_path
    # clients_path
  end

  def after_sign_up_path_for(resource)
    clients_path
  end
end
