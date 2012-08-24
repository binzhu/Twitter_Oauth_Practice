require 'test_helper'

class IndexControllerTest < ActionController::TestCase
  test "should get unfollow" do
    get :unfollow
    assert_response :success
  end

  test "should get follow" do
    get :follow
    assert_response :success
  end

end
