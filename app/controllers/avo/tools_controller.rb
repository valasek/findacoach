class Avo::ToolsController < Avo::ApplicationController
  def dashboard
    @page_title = "Dashboard"
    add_breadcrumb "Dashboard"
    @users = User.left_joins(:clients).group(:id).order("COUNT(clients.id) DESC")
  end
end
