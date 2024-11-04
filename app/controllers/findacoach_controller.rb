class FindacoachController < ApplicationController
  def index
    @users = User.all
    @total_hours = Session.sum(:duration)
  end

  def Security
    begin
      1 / 0
    rescue ZeroDivisionError => exception
      Sentry.capture_exception(exception)
    end
    Sentry.capture_message("test message")
  end
end
