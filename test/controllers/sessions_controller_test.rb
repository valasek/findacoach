require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:one)  # You'll need a client fixture
  end

  test "should get index redirects guest to log in" do
    get client_sessions_path(@client)
    # assert_response :success
    assert_redirected_to new_user_session_path
  end

  test "should get show redirects guest to log in" do
    session = sessions(:one)  # You'll need a session fixture
    get client_session_path(@client, session)
    assert_redirected_to new_user_session_path
    # assert_response :success
  end

  test "should get new redirects guest to log in" do
    get new_client_session_path(@client)
    # assert_response :success
    assert_redirected_to new_user_session_path
  end

  test "should get edit redirects guest to log in" do
    session = sessions(:one)
    get edit_client_session_path(@client, session)
    assert_redirected_to new_user_session_path
    # assert_response :success
  end

  test "should create session" do
    fixture_session = sessions(:two)
    assert_difference("Session.count") do
      post client_sessions_path(@client), params: { session: {
        client_id: @client.id,
        date: fixture_session.date,
        duration: fixture_session.duration,
        notes: fixture_session.notes,
        paid: fixture_session.paid
      } }
    end

    assert_redirected_to client_session_path(@client, Session.last)
  end

  test "should update session redirects guest to login" do
    fixture_session = sessions(:two)
    session = sessions(:one)
    patch client_session_path(@client, session), params: { session: {
      client_id: @client.id,
      date: fixture_session.date,
      duration: fixture_session.duration,
      notes: fixture_session.notes,
      paid: fixture_session.paid
    } }
    assert_redirected_to new_user_session_path
    # assert_redirected_to client_session_path(@client, session)
  end

  test "should destroy session" do
    session = sessions(:one)
    assert_difference("Session.count", -1) do
      delete client_session_path(@client, session)
    end

    assert_redirected_to client_sessions_path(@client)
  end
end
