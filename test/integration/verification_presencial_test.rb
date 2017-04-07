require "test_helper"
require "integration/concerns/login_helpers"
require "integration/concerns/verification_helpers"

class VerificationPresencialTest < JsFeatureTest
  include Participa::Test::LoginHelpers
  include Participa::Test::VerificationHelpers

  around do |&block|
    with_verifications(presential: true) { super(&block) }
  end

  test "anonymous users can't verify presentially" do
    visit verification_step1_path
    assert_equal root_path(locale: :es), page.current_path
  end

  test "presential verificators have normal access to other sections" do
    # initialize
    election = create(:election)

    # should see the pending verification message if isn't verified
    login create(:user)
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

    # should see the pending verification message if isn't verified
    login(user)
    refute_content "Por seguridad, debes confirmar tu teléfono."

    # can't access verification admin
    visit verification_step1_path
    assert_equal root_path(locale: "es"), page.current_path
  end

  test "users verified presentially can't vote page if voting is closed" do
    # initialize
    user = create(:user, :verified_presentially)
    election = create(:election, :closed)
    login(user)

    # can't access vote
    visit create_vote_path(election_id: election.id)
    assert_equal root_path(locale: "es"), page.current_path
  end

  test "users verified presentially can vote page if voting is opened" do
    # initialize
    user = create(:user, :verified_presentially)
    election = create(:election, :opened)
    login(user)

    # can't access vote
    visit create_vote_path(election_id: election.id)
    assert_equal create_vote_path(election_id: election.id), page.current_path
  end

  test "presential verifiers can verify users presentially" do
    user = create(:user)

    # verification can verify user
    verificator = create(:user, :verifying_presentially)
    login(verificator)
    visit verification_step1_path
    fill_in(:user_email, with: user.email)
    click_button('Siguiente')
    assert_content I18n.t('verification.result')
    click_link('Verificar')
    assert_content I18n.t('verification.alerts.ok.title')
    logout

    # should see the OK verification message
    login(user)
    assert_content I18n.t('voting.election_none')
  end

  test "presential verifiers can reject users presentially" do
    user = create(:user)

    # verification can verify user
    verificator = create(:user, :verifying_presentially)
    login(verificator)
    visit verification_step1_path
    fill_in(:user_email, with: user.email)
    click_button('Siguiente')
    assert_content I18n.t('verification.result')
    click_link('No verificar')
    assert_content I18n.t('verification.alerts.ko.title')
    logout

    # should not see the OK verification message
    login(user)
    refute_content I18n.t('voting.election_none')
  end

  test "presential verifiers cannot verify unconfirmed users" do
    unconfirmed_user = create(:user, confirmed_at: nil)

    verificator = create(:user, :verifying_presentially)
    login(verificator)
    visit verification_step1_path
    fill_in(:user_email, with: unconfirmed_user.email)

    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      click_button('Siguiente')
    end

    assert_content <<~MSG.squish
      La persona con email #{unconfirmed_user.email} no ha confirmado su
      correo electrónico. Le acabamos de enviar un nuevo correo de confirmación
      para que pueda confirmar su correo, verificarse y votar.
    MSG

    refute \
      unconfirmed_user.reload.is_verified_presentially?,
      "User shouldn't be verified presentially but it is"
  end
end
