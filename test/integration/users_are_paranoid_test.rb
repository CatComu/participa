require "test_helper"
require "integration/concerns/registration_helpers"

class UsersAreParanoidTest < JsFeatureTest
  include Participa::Test::RegistrationHelpers

  test "regular registration" do
    @user = build(:user)
    # first creation attempt, receive OK message and create it
    assert_equal 0, User.all.count
    create_user_registration(@user, @user.document_vatid, @user.email)
    assert_content I18n.t("devise.registrations.signed_up_but_unconfirmed")
    assert_equal 1, User.all.count
  end

  test "creation with dup document and email" do
    @user = create(:user)
    # receive OK message
    # but don't create the user and mail them a message
    create_user_registration(@user, @user.document_vatid, @user.email)
    assert_content I18n.t("devise.registrations.signed_up_but_unconfirmed")
    assert_equal 1, User.all.count
  end

  test "creation with same document and invalid email" do
    @user = create(:user)
    # receive KO message
    # don't create it because it has errors.
    # should receive validation error.
    create_user_registration(@user, @user.document_vatid, "trolololo")
    assert_content "La dirección de correo es incorrecta"
    assert_equal 1, User.all.count
  end

  test "creation the same document and different email" do
    @user = create(:user)
    # receive OK message
    # but don't create the user and mail them a message to original account
    create_user_registration(@user, @user.document_vatid, "trolololo@example.com")
    assert_content I18n.t("devise.registrations.signed_up_but_unconfirmed")
    assert_equal 1, User.all.count
  end
end
