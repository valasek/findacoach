require "test_helper"

class PwaControllerTest < ActionDispatch::IntegrationTest
  test "manifest path redirects to json endpoint" do
    get "/manifest"

    assert_redirected_to "/manifest.json"

    follow_redirect!
    assert_response :success
    assert_match(/json/, response.media_type)
  end

  test "manifest json endpoint is accessible" do
    get pwa_manifest_path

    assert_response :success
    assert_match(/json/, response.media_type)
  end
end
