require 'test_helper'

class WorkflowControllerTest < ActionController::TestCase
  test "should get my" do
    get :my
    assert_response :success
  end

  test "should get managed" do
    get :managed
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get view" do
    get :view
    assert_response :success
  end

end
