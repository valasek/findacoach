# frozen_string_literal: true

require "net/http"
require "json"

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]
  before_action :set_profile, only: [ :edit, :update ]
  before_action :check_honeypot, only: [ :create ]
  before_action :verify_turnstile, only: [ :create ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def update_resource(resource, params)
    if params[:password].blank?
      # Remove password-related params for profile-only updates
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  private

  def set_profile
    @profile = current_user.user_profile || current_user.create_user_profile!
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ user_profile_attributes: [ :full_name, :phone ] ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      user_profile_attributes: [ :id, :full_name, :phone, :bio, :website, :photo, :username ]
    ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up for inactive accounts (email confirmation pending).
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def check_honeypot
    # Silently discard requests where the hidden bot-trap field was filled.
    # Legitimate users never see this field thanks to CSS positioning.
    if params.dig(:user, :website_url).present?
      redirect_to new_user_session_path and return
    end
  end

  def verify_turnstile
    return unless turnstile_configured?

    token = params["cf-turnstile-response"].to_s
    # Fail open: if JS didn't load (CDN outage / script blocker) the token will
    # be absent. The honeypot and rate limiter remain active as a fallback.
    return if token.blank?

    unless turnstile_valid?(token)
      build_resource(sign_up_params)
      flash.now[:alert] = "Security verification failed. Please try again."
      render :new, status: :unprocessable_entity
    end
  end

  def turnstile_configured?
    Rails.application.credentials.cloudflare&.dig(:turnstile_secret_key).present?
  end

  def turnstile_valid?(token)
    uri = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 3
    http.read_timeout = 3
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(
      "secret" => Rails.application.credentials.cloudflare[:turnstile_secret_key],
      "response" => token,
      "remoteip" => request.ip
    )
    response = http.request(req)
    JSON.parse(response.body)["success"] == true
  rescue StandardError
    true # fail open on network errors
  end
end
