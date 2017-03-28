require 'test_helper'

class VoteControllerTest < ActionController::TestCase

  around do |&block|
    @user = create(:user, :confirmed_by_sms)
    @election = create(:election)

    with_verifications(online: true, presential: true) { super(&block) }
  end

  test "should not get create as anon" do
    get :create, params: { election_id: @election.id }
    assert_response :redirect
    assert_redirected_to "/users/sign_in" # FIXME bug con locales
  end

  test "should not get create as unverified user" do
    @election.update_attributes(starts_at: DateTime.now-7.days, ends_at: DateTime.now+10.days)
    sign_in create(:user)
    get :create, params: { election_id: @election.id }
    assert_response :redirect
    assert_redirected_to root_url(locale: 'es')
    #assert response.header["Location"].starts_with? "https://vota.podemos.info/"
  end

  test "should get create as user" do
    @election.update_attributes(starts_at: DateTime.now-7.days, ends_at: DateTime.now+10.days)
    sign_in @user
    get :create, params: { election_id: @election.id }
    assert_response :success
    #assert response.header["Location"].starts_with? "https://vota.podemos.info/"
  end

  test "should give invalid date limit if election is not active" do
    @election.update_attributes(starts_at: DateTime.now-30.days, ends_at: DateTime.now-7.days)
    sign_in @user
    get :create, params: { election_id: @election.id }
    assert_not @election.is_active?
    assert_response :redirect
    assert_redirected_to root_url
    assert_equal(I18n.t('podemos.election.close_message'), flash[:error])
  end

  test "should give 'no election on location' error if there is a vote not on user's location" do
    ElectionLocation.create(election_id: @election.id, location: "11111")
    @election.update_attributes(scope: 3, starts_at: DateTime.now-7.days, ends_at: DateTime.now+10.days)
    sign_in @user
    get :create, params: { election_id: @election.id }
    assert_response :redirect
    assert_redirected_to root_url
    assert_equal(I18n.t('podemos.election.no_location'), flash[:error])

    ElectionLocation.create(election_id: @election.id, location: @user.vote_town_numeric, agora_version: 0)
    @election.update_attributes(scope: 3, starts_at: DateTime.now-7.days, ends_at: DateTime.now+10.days)
    get :create, params: { election_id: @election.id }
    assert_response :success
  end

end
