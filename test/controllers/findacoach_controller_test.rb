require "test_helper"

class FindacoachControllerTest < ActionDispatch::IntegrationTest
  test "coach homepage is accessible without login" do
    get coach_homepage_url(username: user_profiles(:one).username)
    assert_response :success
  end

  test "old bare username path returns 404" do
    get "/#{user_profiles(:one).username}"
    assert_response :not_found
  end

  test "spam php probe paths return 404" do
    get "/pol.php"
    assert_response :not_found
  end
end
