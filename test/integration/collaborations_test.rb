require "test_helper"

class CollaborationsTest < ActionDispatch::IntegrationTest
  around do |&block|
    with_verifications(sms: false, presential: false) { super(&block) }
  end

  test "new collaboration" do
    # anonymous
    visit new_collaboration_path
    assert_content "Necesitas iniciar sesión o registrarte para continuar."

    # logged in user (no collaboration)
    user = create(:user)
    login_as(user)
    visit new_collaboration_path
    assert_content "Declaro ser mayor de 18 años."

    # logged in user (with unconfirmed collaboration)
    collaboration = create(:collaboration, user: user)
    visit new_collaboration_path
    assert_content "Revisa y confirma todos los datos para activar la colaboración."
  end

  test "a user should be able to add and destroy a new collaboration" do
    user = create(:user)
    assert_equal 0, Collaboration.all.count 

    # logged in user, fill collaboration
    login_as(user)
    visit new_collaboration_path
    #assert_content "Colaborando con Podemos conseguirás que este proyecto siga creciendo mes a mes"
    assert_content "Apúntate a las donaciones periódiques de BComú"
    select('500', :from=>'Importe mensual') 
    select('Trimestral', :from=>'Frecuencia de pago') 
    select('Domiciliación en cuenta bancaria (formato IBAN)', :from=>'Método de pago') 
    fill_in('collaboration_iban_account', :with => "ES0690000001210123456789")
    fill_in('collaboration_iban_bic', :with => "ESPBESMMXXX")
    check('collaboration_terms_of_service')
    check('collaboration_minimal_year_old') 

    click_button "Guardar Colaboración económica"
    assert_content "6.000,00€"
    assert_equal 1, Collaboration.all.count 

    # confirm collaboration
    click_link "Confirmar"
    assert_content "Tu donación se ha dado de alta correctamente."

    # modify collaboration
    visit new_collaboration_path
    assert_content "Ya tienes una colaboración"

    # destroy collaboration
    click_link "Dar de baja colaboración"
    assert_content "Hemos dado de baja tu colaboración."
    assert_equal 0, Collaboration.all.count 
  end

  test "a user should be able to add and destroy a new collaboration with orders" do
    user = create(:user)
    assert_equal 0, Collaboration.all.count 

    login_as(user)
    visit new_collaboration_path
    #assert_content "Colaborando con Podemos conseguirás que este proyecto siga creciendo mes a mes"
    assert_content "Apúntate a las donaciones periódiques de BComú"

    select('500', :from=>'Importe mensual') 
    select('Trimestral', :from=>'Frecuencia de pago') 
    select('Domiciliación en cuenta bancaria (formato IBAN)', :from=>'Método de pago') 
    fill_in('collaboration_iban_account', :with => "ES0690000001210123456789")
    fill_in('collaboration_iban_bic', :with => "ESPBESMMXXX")
    check('collaboration_terms_of_service')
    check('collaboration_minimal_year_old') 

    click_button "Guardar Colaboración económica"
    assert_content "6.000,00€"
    assert_equal 1, Collaboration.all.count 

    click_link "Confirmar"
    assert_content "Tu donación se ha dado de alta correctamente."

    # modify collaboration
    visit new_collaboration_path
    assert_content "Ya tienes una colaboración"

    collaboration = Collaboration.all.last
    order = collaboration.create_order Date.today+1.day
    assert order.save
    assert_equal 1, Order.all.count

    # destroy collaboration
    click_link "Dar de baja colaboración"
    assert_content "Hemos dado de baja tu colaboración."

    assert_equal 0, Collaboration.all.count 
    assert_equal 1, Order.all.count
  end

end
