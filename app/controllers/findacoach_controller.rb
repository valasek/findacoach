class FindacoachController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
    @clients_count = Client.count
    @clients_archived = Client.filter_by_archive_status("archived").count
    @clients_unarchived = Client.filter_by_archive_status("unarchived").count
  end
end
