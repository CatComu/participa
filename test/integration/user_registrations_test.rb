require "test_helper"
require "integration/concerns/registration_helpers"

class UserRegistrationsTest < JsFeatureTest
  include Participa::Test::RegistrationHelpers

  test "catalonia_residence is checked by default" do
    visit new_user_registration_path

    assert page.has_checked_field?("Resido en Cataluña")
  end

  test "create a user in Catalonia" do
    @user = build(:user, :catalan, town: 'm_08_015_5',
                                   comarca: 13,
                                   vegueria: 'AT01')

    base_register(@user) { fill_in_location_data(@user) }

    assert_location User.first, town: 'Badalona',
                                province: 'Barcelona',
                                country: 'España'

    assert User.first.comarca_code, 13
    assert User.first.vegueria_code, 'AT01'
  end

  test "allows the youngest (16 years old) to register" do
    user = build(:user, born_at: 16.years.ago)
    visit new_user_registration_path
    fill_in('Nombre', with: user.first_name)
    fill_in('Apellidos', with: user.last_name)
    select("Pasaporte", from: "Tipo de documento")
    fill_in('DNI', with: user.document_vatid)

    fill_in_born_date(user.born_at.year,
                      I18n.l(user.born_at, format: "%B"),
                      user.born_at.day)

    fill_in_location_data(user)
    fill_in_login_data(user, user.email)
    acknowledge_stuff
    click_button "Inscríbete"

    assert_content \
      I18n.t("devise.registrations.signed_up_but_unconfirmed")
  end

  test "create a user outside of Catalonia" do
    @user = build(:user, :spanish, province: 'AB',
                                   town: 'm_02_003_0',
                                   postal_code: '02002')

    base_register(@user) { fill_in_location_data(@user) }

    assert_location User.first, town: 'Albacete',
                                province: 'Albacete',
                                country: 'España'
  end

  test "create a user outside of Spain" do
    @user = build(:user, :foreigner, country: 'US', province: 'AL')

    base_register(@user) { fill_in_location_data(@user) }

    assert_location User.first, province: 'Alabama', country: 'Estados Unidos'
  end

  test "create a user in a country without regions" do
    @user = build(:user, :foreigner, country: 'MC', province: nil)

    base_register(@user) { fill_in_location_data(@user) }

    assert_location User.first, province: '', country: 'Mónaco'
  end

  test "location is preserved upon form errors" do
    @user = build(:user, :foreigner, country: 'US', province: 'AL')

    visit new_user_registration_path
    fill_in_location_data(@user)
    click_button 'Inscríbete'

    assert_select 'País', selected: 'Estados Unidos'
    assert_select 'Provincia', selected: 'Alabama'
  end

  test "create a user with gender identity information" do
    @user = build(:user, :catalan)

    visit new_user_registration_path
    fill_in_user_registration(@user, @user.document_vatid, @user.email)
    select 'Mujer (cis)', from: 'Identidad de género'
    click_button 'Inscríbete'

    assert_content \
      I18n.t("devise.registrations.signed_up_but_unconfirmed")

    assert_equal true, User.first.gender_identity.cis_woman?
  end

  test "captcha skipped" do
    @user = build(:user, :catalan)

    visit new_user_registration_path
    fill_in_personal_data(@user, @user.document_vatid)
    fill_in_location_data(@user)
    fill_in_login_data(@user, @user.email)
    acknowledge_terms
    acknowledge_age
    click_button 'Inscríbete'
    assert_text 'El texto introducido no corresponde con el de la imagen'
  end

  test "captcha skipped and another error" do
    @user = build(:user, :catalan)

    visit new_user_registration_path
    fill_in_personal_data(@user, @user.document_vatid)
    fill_in_location_data(@user)
    fill_in_login_data(@user, @user.email)
    acknowledge_age
    # Investigate and fix
    find_button('Inscríbete').trigger('click')
    assert_text 'El texto introducido no corresponde con el de la imagen'
    assert_text 'He leído las condiciones y acepto inscribirme'
  end

  private

  def base_register(user)
    assert_equal 0, User.all.count
    visit new_user_registration_path
    fill_in_personal_data(user, user.document_vatid)
    yield
    fill_in_login_data(user, user.email)
    acknowledge_stuff
    click_button "Inscríbete"

    assert_content \
      I18n.t("devise.registrations.signed_up_but_unconfirmed")
  end

  def assert_location(user, town: nil, province:, country:)
    assert_equal town, user.town_name if town
    assert_equal province, user.province_name
    assert_equal country, user.country_name
  end
end
