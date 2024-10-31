class DashboardController < ApplicationController
  def index
    @clients_count = current_user.clients.count
    @hours_count = current_user.total_coaching_hours
    @sessions_paid = current_user.percentage_paid_sessions
    @sessions_count = current_user.sessions.count
  end
end
