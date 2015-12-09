require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get profile_update" do
    get :profile_update
    assert_response :success
  end

end
