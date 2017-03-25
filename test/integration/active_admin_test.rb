require "test_helper"

class ActiveAdminTest < ActionDispatch::IntegrationTest
  test "anonymous users can't access the admin" do
    visit admin_users_path
    assert_content "No tienes permisos para acceder a esa sección "
  end

  test "unverified normal user shouldn't access the admin with both verifications" do
    with_verifications(sms: true, presential: true) do
      user = create(:user)
      login_as(user)
      visit admin_collaborations_path
      assert_content "No tienes permisos para acceder a esa sección "
    end
  end

  test "unverified normal user shouldn't access the admin with only presential verifications" do
    with_verifications(sms: false, presential: true) do
      user = create(:user)
      login_as(user)
      visit admin_collaborations_path
      assert_content "No tienes permisos para acceder a esa sección "
    end
  end

  test "unverified normal user shouldn't access the admin with only online verifications" do
    with_verifications(sms: true, presential: false) do
      user = create(:user)
      login_as(user)
      visit admin_collaborations_path
      assert_content "Por seguridad, debes confirmar tu teléfono"
    end
  end

  test "verified normal user shouldn't access the admin with both verifications" do
    with_verifications(sms: true, presential: true) do
      user = create(:user, :confirmed_by_sms)
      login_as(user)
      visit admin_collaborations_path
      assert_content "No tienes permisos para acceder a esa sección "
    end
  end

  test "verified normal user shouldn't access the admin with only presential verifications" do
    with_verifications(sms: false, presential: true) do
      user = create(:user, :confirmed_by_sms)
      login_as(user)
      visit admin_collaborations_path
      assert_content "No tienes permisos para acceder a esa sección "
    end
  end

  test "verified normal user shouldn't access the admin with only online verifications" do
    with_verifications(sms: true, presential: false) do
      user = create(:user, :confirmed_by_sms)
      login_as(user)
      visit admin_collaborations_path
      assert_content "No tienes permisos para acceder a esa sección "
    end
  end

  test "admin user should access the admin" do
    user = create(:user, :admin)
    login_as(user)
    visit admin_users_path
    assert_content "Salir"
    assert_content "Usuario"
    assert_content "Perez Pepito"
  end

end 
