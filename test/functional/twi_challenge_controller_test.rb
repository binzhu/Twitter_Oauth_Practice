require 'test_helper'

class TwiChallengeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get unfollow" do
    get :unfollow
    assert_response :success
  end

  test "should get follow" do
    get :follow
    assert_response :success
  end

end
