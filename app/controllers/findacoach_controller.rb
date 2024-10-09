class FindacoachController < ApplicationController
  def index
    @users = User.all
  end
end
