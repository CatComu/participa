require "test_helper"
require "integration/concerns/login_helpers"

class VerificationPresencialTest < JsFeatureTest
  include Participa::Test::LoginHelpers

  around do |&block|
    with_verifications(presential: true) { super(&block) }
  end

  test "users need to be verified to access other tools" do
    # cant access as anon
    visit verification_step1_path
    assert_equal page.current_path, root_path(locale: :es)

    # initialize
    user = create(:user)
    election = create(:election)

    # should see the pending verification message if isn't verified
    login(user)
    assert_content pending_verification_message

    # can't access verification admin
    visit verification_step1_path
    assert_equal pending_verification_path, page.current_path

    # can't access vote
    visit create_vote_path(election_id: election.id)
    assert_content pending_verification_message
  end

  test "users verified presentially are not bothered with online confirmations" do
    # initialize
    user = create(:user, :verified_presentially)
    election = create(:election)

    # should see the pending verification message if isn't verified
    login(user)
    refute_content "Por seguridad, debes confirmar tu teléfono."

    # can't access verification admin
    visit verification_step1_path
    assert_equal root_path(locale: "es"), page.current_path

    # can't access vote
    visit create_vote_path(election_id: election.id)
    assert_equal root_path(locale: "es"), page.current_path
  end

  test "presential verifiers can verify users presentially" do
    # should see the pending verification message if isn't verified
    user2 = create(:user)
    login(user2)
    assert_content pending_verification_message
    logout

    # user1 can verify user2
    user1 = create(:user, :verifying_presentially, :confirmed_by_sms)
    login(user1)
    visit verification_step1_path
    assert_content I18n.t('verification.form.document')
    check('user_document')
    check('user_town')
    check('user_age_restriction')
    click_button('Siguiente')
    fill_in(:user_email, with: user2.email)
    click_button('Siguiente')
    assert_content I18n.t('verification.result')
    click_button('Si, estos datos coinciden')
    assert_content I18n.t('verification.alerts.ok.title')
    logout

    # should see the OK verification message
    login(user2)
    assert_content I18n.t('voting.election_none')
    logout
  end

  private

  def pending_verification_message
    if Features.presential_verifications?
      "¡Sólo te queda una última verificación por hacer!"
    else
      "Por seguridad, debes confirmar tu teléfono."
    end
  end

  def pending_verification_path
    if Features.presential_verifications?
      root_path(locale: "es")
    else
      sms_validator_step1_path(locale: "es")
    end
  end
end
