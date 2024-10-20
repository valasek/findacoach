class DashboardController < ApplicationController
  def index
    @clients_count = current_user.clients.count
    @hours_count = current_user.total_coaching_hours
    @coaching_sessions_paid = current_user.percentage_paid_sessions
    @coaching_sessions_count = current_user.sessions.count
  end
end
