class FindacoachController < ApplicationController
  def index
    @users = User.all
    @total_hours = Session.sum(:duration)
  end
end
