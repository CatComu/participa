require "test_helper"

class VerificationPresencialTest < JsFeatureTest

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
    login_as(user)
    visit root_path
    assert_content pending_verification_message

    # can't access verification admin
    visit verification_step1_path
    assert_equal pending_verification_path, page.current_path

    # can't access vote
    visit create_vote_path(election_id: election.id)
    assert_content pending_verification_message

  end

  test "users verified presentially are not bothered with sms confirmations" do
    # initialize
    user = create(:user, :verified_presentially)
    election = create(:election)

    # should see the pending verification message if isn't verified
    login_as(user)
    visit root_path
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
    login_as(user2)
    visit root_path
    assert_content pending_verification_message
    logout(user2)

    # user1 can verify user2
    user1 = create(:user, :verifying_presentially, :confirmed_by_sms)
    login_as(user1)
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
    logout(user1)

    # should see the OK verification message
    login_as(user2)
    visit root_path
    assert_content I18n.t('voting.election_none')
    logout(user2)
  end

  private

  def pending_verification_message
    if Features.online_verifications?
      "Por seguridad, debes confirmar tu teléfono."
    else
      "No has finalizado la verificación"
    end
  end

  def pending_verification_path
    if Features.online_verifications?
      sms_validator_step1_path(locale: "es")
    else
      root_path(locale: "es")
    end
  end
end
