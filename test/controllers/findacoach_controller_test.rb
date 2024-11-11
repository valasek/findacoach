require "test_helper"

class FindacoachControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get findacoach_url
    assert_response :success
  end
end
