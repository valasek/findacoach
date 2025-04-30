class FindacoachController < ApplicationController
  def index
    @total_users = User.all.count # for now lets count demo user as well
    # demo_users_hours = User.find_by(email: "demo@example.com").sessions.sum(:duration)
    @total_hours = Session.sum(:duration) # for now lets count demo_users_hours as well
  end

  def Security
  end

  def adminland
    @users = User.all
  end
end
