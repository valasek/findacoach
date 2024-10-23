class HealthController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :up ]
  rescue_from(Exception) { render head: 503 }

  def up
    render json: { status: "UP" }, status: :ok
  end
end
