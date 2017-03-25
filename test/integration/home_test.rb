require 'test_helper'
require 'integration/concerns/login_helpers'

class HomeTest < ActionDispatch::IntegrationTest
  include Participa::Test::LoginHelpers

  test "shows login page for anonymous users" do
    visit root_path
    assert_title "Iniciar sesión"
  end

  test "sets locale from default_url_options by default" do
    I18n.with_locale(:es) do
      visit root_path
      assert_equal '/es', page.current_path
    end
  end

  test "sets locale from url" do
    I18n.with_locale(:es) do
      visit root_path(locale: 'ca')

      assert_equal(:ca, I18n.locale)
    end
  end

  test "allows foreign users to login" do
    with_verifications(presential: false, sms: false) do
      login create(:user, country: "DE", province: "BE", town: nil)
      assert_title "Datos personales"
    end
  end

  test "allows rare foreign users (no province) to login" do
    with_verifications(presential: false, sms: false) do
      login create(:user, country: "PS", province: nil, town: nil)
      assert_title "Datos personales"
    end
  end

  test "allows access to profile to unverified users" do
    with_verifications(presential: false, sms: true) do
      login create(:user)
      visit edit_user_registration_path
      assert_title 'Datos personales'
    end
  end

  test "allows access to static pages to unverified users" do
    with_verifications(presential: false, sms: true) do
      login create(:user)
      visit page_privacy_policy_path
      assert_title 'Política de Privacidad'
    end
  end

  test "redirects to edit profile when no verifications enabled" do
    with_verifications(presential: false, sms: false) do
      login create(:user)
      visit root_path
      assert_title "Datos personales"
    end
  end

  test "shows verification page when only presential verifications enabled" do
    with_verifications(presential: true, sms: false) do
      login create(:user)
      visit root_path
      assert_title "No te has verificado"
    end
  end

  test "redirects to sms verification when only sms verifications enabled" do
    with_verifications(presential: false, sms: true) do
      login create(:user)
      visit root_path
      assert_title "Envíanos la documentación"
    end
  end

  test "shows election page when only sms verifications enabled & user verified" do
    with_verifications(presential: false, sms: true) do
      login create(:user, :confirmed_by_sms)
      visit root_path
      assert_title "Usuario/a verificado/a | Votación"
    end
  end

  test "redirects to sms verification when both verifications enabled & user not verified" do
    with_verifications(presential: true, sms: true) do
      login create(:user)
      visit root_path
      assert_title "Envíanos la documentación"
    end
  end

  test "shows election page when both verifications enabled & user verified presentially" do
    with_verifications(presential: true, sms: true) do
      login create(:user, :verified_presentially)
      visit root_path
      assert_title "Usuario/a verificado/a | Votación"
    end
  end

  test "shows election page when both verifications enabled & user verified by sms" do
    with_verifications(presential: true, sms: true) do
      login create(:user, :confirmed_by_sms)
      visit root_path
      assert_title "Usuario/a verificado/a | Votación"
    end
  end
end
