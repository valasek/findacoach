class FindacoachController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
    @clients_count = Client.count
    @clients_archived = Client.archived.count
    @clients_unarchived = Client.unarchived.count
  end
end
