require 'test_helper'

class LogControllerTest < ActionController::TestCase
  test "should get in" do
    get :in
    assert_response :success
  end

  test "should get out" do
    get :out
    assert_response :success
  end

end
