require 'test_helper'
require 'integration/concerns/login_helpers'

class HomeTest < ActionDispatch::IntegrationTest
  include Participa::Test::LoginHelpers

  test "shows login page for anonymous users" do
    visit root_path
    assert_title "Iniciar sesión"
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
      assert_title "Introduce tu número de teléfono móvil"
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
      assert_title "Introduce tu número de teléfono móvil"
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
