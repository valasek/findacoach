class HealthController < ApplicationController
  rescue_from(Exception) { render head: 503 }

  def up
    render json: { status: "UP" }, status: :ok
  end
end
