require "test_helper"
require "integration/concerns/login_helpers"
require "integration/concerns/verification_helpers"

class VerificationOnlineTest < JsFeatureTest
  include Participa::Test::LoginHelpers
  include Participa::Test::VerificationHelpers

  around do |&block|
    with_verifications(online: true) { super(&block) }
  end

  test "anonymous users can't verify online" do
    visit online_verifications_path
    assert_equal root_path(locale: :es), page.current_path
  end

  test "online verificators have normal access to other sections" do
    # initialize
    election = create(:election)

    # should see the pending verification message if isn't verified
    login create(:user)
    assert_content pending_verification_message

    # can't access verification admin
    visit online_verifications_path
    assert_equal pending_verification_path, page.current_path

    # can't access vote
    visit create_vote_path(election_id: election.id)
    assert_content pending_verification_message
  end

  test "users verified online are not bothered with presential confirmations" do
    # initialize
    user = create(:user, :verified_online, :confirmed_by_sms)

    # should see the pending verification message if isn't verified
    login(user)
    refute_content "¡Sólo te queda una última verificación por hacer!"

    # can't access verification admin
    visit online_verifications_path
    assert_equal root_path(locale: "es"), page.current_path
  end

  test "users verified presentially can't vote page if voting is closed" do
    # initialize
    user = create(:user, :verified_online, :confirmed_by_sms)
    election = create(:election, :closed)
    login(user)

    # can't access vote
    visit create_vote_path(election_id: election.id)
    assert_equal root_path(locale: "es"), page.current_path
  end

  test "users verified presentially can vote page if voting is opened" do
    # initialize
    user = create(:user, :verified_online, :confirmed_by_sms)
    election = create(:election, :opened)
    login(user)

    # can't access vote
    visit create_vote_path(election_id: election.id)
    assert_equal create_vote_path(election_id: election.id), page.current_path
  end

  test "only presents the UI if there are no pending verifications" do
    create(:user, first_name: "Miguel", last_name: "Miguelez")
    login create(:user, :verifying_online)
    visit online_verifications_path

    assert_content "No hay usuarias pendientes de verificar en este momento."
  end

  test "allows verifying users" do
    user2 = create(:user, :confirmed_by_sms, first_name: "Miguel",
                                             last_name: "Miguelez")
    login create(:user, :verifying_online)
    visit online_verifications_path

    click_link('Comenzar')
    assert_content "Miguel Miguelez"

    click_link('Aceptar')
    assert_content "No quedan usuarias pendientes de verificación. ¡Buen trabajo!"
    logout

    # should see the OK verification message
    login(user2)
    assert_content I18n.t('voting.election_none')
  end

  test "allows banning users" do
    user2 = create(:user, :confirmed_by_sms, first_name: "Miguel",
                                             last_name: "Miguelez")
    login create(:user, :verifying_online)
    visit online_verifications_path

    click_link('Comenzar')
    assert_content "Miguel Miguelez"

    click_link('Rechazar')
    assert_content "No quedan usuarias pendientes de verificación. ¡Buen trabajo!"
    logout

    # should see the banned message
    login(user2)
    assert_content I18n.t("unauthorized.banned", full_name: user2.full_name)
  end
end
