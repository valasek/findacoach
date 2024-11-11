require "test_helper"

class WhatsNewControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get whatsnew_url
    assert_response :success
  end
end
