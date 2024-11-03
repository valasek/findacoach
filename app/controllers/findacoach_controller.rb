class FindacoachController < ApplicationController
  def index
    @users = User.all
    @total_hours = Session.sum(:duration)
  end

  def Security
  end
end
