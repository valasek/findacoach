require "test_helper"

class FindacoachControllerTest < ActionDispatch::IntegrationTest
  test "landing page leads with online booking requests" do
    get root_url

    assert_response :success
    assert_select "h2", text: "Online bookings, clients, and session notes"
    assert_select "h3", text: "Online booking requests"
    assert_select "p", text: /confirm or decline each request before it becomes a booking/
    assert_select "p", text: /public coach page with your photo, bio, and website/
    assert_select ".mockup-browser img[alt=?]", "Online booking form with available session times"
    assert_select "h3", text: "Professional Coach Profile", count: 0
  end

  test "dashboard explains the public booking page" do
    sign_in users(:oneU)

    get findacoach_dashboard_url

    assert_response :success
    assert_select "a[href=?]", coach_homepage_path(username: users(:oneU).user_profile.username), text: "Your booking page"
    assert_select "p", text: /Share this page with clients so they can choose a time and request a session/
    assert_select "a[href=?]", edit_user_registration_path(tab: "booking"), text: "booking settings"
    assert_select "div", text: /Update the name, photo, bio, and website shown on that page/ do
      assert_select "a[href=?]", edit_user_registration_path, text: "profile settings"
    end
  end

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
