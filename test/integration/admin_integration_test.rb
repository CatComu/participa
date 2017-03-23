require 'test_helper'

class AdminIntegrationTest < ActionDispatch::IntegrationTest

  setup do
    @user = create(:user)
    @admin = create(:user, :admin)
  end

  test "should not get /admin as anon" do
    get '/admin'
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal I18n.t('unauthorized.default'), flash[:error] 
  end

  test "should not get /admin/resque as anon" do
    assert_raises(ActionController::RoutingError) do
      get '/admin/resque'
    end
  end

  test "should not get /admin as normal user" do
    login_as @user
    get '/admin'
    assert_response :redirect
    assert_redirected_to authenticated_root_path
    assert_equal I18n.t('unauthorized.default'), flash[:error] 
  end

  test "should not get /admin/resque as normal user" do
    login_as @user
    assert_raises(ActionController::RoutingError) do
      get '/admin/resque'
    end
  end

  test "should get /admin as admin user" do
    login_as @admin
    get '/admin'
    assert_response :success
  end

  test "should get /admin/resque as admin user" do
    login_as @admin
    get '/admin/resque'
    assert_response :redirect
    assert_redirected_to '/admin/resque/overview'
  end

  test "should not download newsletter CSV as user" do
    login_as @user
    get '/admin/users/download_newsletter_csv'
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal I18n.t('unauthorized.default'), flash[:error] 
  end
    
  #test "should download newsletter CSV as admin and not download wants_newsletter = false" do
  #  login_as @admin
  #  get '/admin/users/download_newsletter_csv'
  #  assert_response :success
  #  assert response["Content-Type"].include? "text/csv"
  #  csv = CSV.parse response.body
  #  assert_equal 2, csv.count

  #  # should not change count with a user with newsletter disabled
  #  create(:user, :newsletter_disabled)
  #  get '/admin/users/download_newsletter_csv'
  #  assert_response :success
  #  assert response["Content-Type"].include? "text/csv"
  #  csv = CSV.parse response.body
  #  assert_equal 2, csv.count

  #  # should change count with a newsletter_user
  #  create(:user, :newsletter_enabled)
  #  get '/admin/users/download_newsletter_csv'
  #  assert_response :success
  #  assert response["Content-Type"].include? "text/csv"
  #  csv = CSV.parse response.body
  #  assert_equal 3, csv.count
  #end

end
