require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect guest from index to log" do
    get dashboard_index_url
    assert_redirected_to new_user_session_path
  end
end
