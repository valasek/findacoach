require "application_system_test_case"
require "warden/test/helpers"

class MobileLayoutTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @client = clients(:oneC)
    @session = sessions(:oneS)
    login_as users(:oneU), scope: :user
    page.current_window.resize_to(375, 812)
  end

  teardown do
    Warden.test_reset!
    page.current_window.resize_to(1400, 1400)
  end

  test "primary screens fit a mobile viewport" do
    [
      root_url,
      clients_url,
      new_client_url,
      edit_client_url(@client),
      client_url(@client),
      start_session_url,
      new_client_session_url(@client),
      edit_client_session_url(@client, @session),
      client_session_url(@client, @session),
      edit_user_registration_url
    ].each do |url|
      visit url
      assert_no_horizontal_overflow
    end
  end

  private

    def assert_no_horizontal_overflow
      viewport_width, page_width = page.evaluate_script(<<~JS)
        [document.documentElement.clientWidth, document.documentElement.scrollWidth]
      JS

      assert_equal viewport_width, page_width, "#{page.current_path} overflows horizontally"
    end
end
