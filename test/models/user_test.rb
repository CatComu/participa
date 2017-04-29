require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "validates presence:true" do
    u = User.new
    u.valid?
    fields = %i(email password first_name last_name document_type document_vatid born_at postal_code)
    fields.each do |type|
      assert_includes u.errors[type], I18n.t("activerecord.errors.models.user.attributes.#{type}.blank")
    end
  end

  test "validates presence of town for Spain users" do
    u = build(:user, country: 'ES', town: nil)
    u.valid?
    assert_includes u.errors[:town], "Tu municipio no puede estar en blanco"
  end

  test "validates absence of town for foreign users" do
    u = build(:user, country: 'BR', town: 'Río de Janeiro')
    u.valid?
    assert_includes u.errors[:town], "Tu municipio debe estar en blanco"
  end

  test "validates document_vatid with DNI/NIE" do
    u = build(:user, document_type: 1, document_vatid: "222222E")
    u.valid?
    assert_includes u.errors[:document_vatid], "El DNI no es válido"

    u = build(:user, document_type: 2, document_vatid: "222222E")
    u.valid?
    assert_includes u.errors[:document_vatid], "El NIE no es válido"

    u = build(:user, document_type: 1, document_vatid: "99115002K")
    u.valid?
    assert_empty u.errors[:document_vatid]

    u = build(:user, document_type: 2, document_vatid: "Z4901305X")
    u.valid?
    assert_empty u.errors[:document_vatid]
  end

  test "validates email uniqueness" do
    user = create(:user)
    error_message = I18n.t "activerecord.errors.models.user.attributes.email.taken"
    user2 = build(:user, email: user.email)
    user2.valid?
    assert_includes user2.errors[:email], error_message

    user2 = build(:user, email: "newuniqueemail@example.com")
    user2.valid?
    assert_empty user2.errors[:email]
  end

  test "validates email format" do
    user = build :user, email: "right_format@example.com"
    user.valid?
    assert_equal [], user.errors[:email], "Right format detected as invalid"

    user = build :user, email: "Right.Format.2@example.com"
    user.valid?
    assert_equal [], user.errors[:email], "Right format detected as invalid"

    user = build :user, email: "stránge_chars@example.com"
    user.valid?
    assert_equal ["La dirección de correo no puede contener acentos, eñes u otros caracteres especiales"], user.errors[:email], "Strange chars not detected"

    user = build :user, email: "STRÁNGE_CHARS@EXAMPLE.COM"
    user.valid?
    assert_equal ["La dirección de correo no puede contener acentos, eñes u otros caracteres especiales"], user.errors[:email], "Strange chars not detected"

    user = build :user, email: "double..dot@example.com"
    user.valid?
    assert_equal ["La dirección de correo no puede contener dos puntos seguidos"], user.errors[:email], "Dot-dot not detected"

    user = build :user, email: ".firstchar@example.com"
    user.valid?
    assert_equal ["La dirección de correo debe comenzar con un número o una letra"], user.errors[:email], "First letter invalid not detected"

    user = build :user, email: "lastchar@example.com."
    user.valid?
    assert_equal ["La dirección de correo debe acabar con una letra"], user.errors[:email], "Wrong domain not detected"

    user = build :user, email: "lastchar@example,com"
    user.valid?
    assert_equal ["La dirección de correo contiene caracteres inválidos"], user.errors[:email], "Comma in domain not detected"

    user = build :user, email: "last,char@example.com"
    user.valid?
    assert_equal ["La dirección de correo contiene caracteres inválidos"], user.errors[:email], "Unescaped comma in local not detected"

    user = build :user, email: "\"last,char\"@example.com"
    user.valid?
    assert_equal [], user.errors[:email], "Quoted comma in local detected as invalid"

    user = build :user, email: "wrong_domain@examplecom"
    user.valid?
    assert_equal ["La dirección de correo es incorrecta"], user.errors[:email], "Wrong domain (no dots) not detected"
  end

  test "validates email confirmation in a case insensitive way" do
    user = build :user, email: "email@example.org", email_confirmation: "Email@example.org"
    user.valid?
    assert_empty user.errors[:email_confirmation]
  end

  test "validates document_vatid uniqueness" do
    error_message = I18n.t "activerecord.errors.models.user.attributes.document_vatid.taken"

    #  try to save with the same document
    user1 = create(:user)
    user2 = build(:user, document_vatid: user1.document_vatid)
    user2.valid?
    assert_includes user2.errors[:document_vatid], error_message

    # downcase ( minusculas )
    user3 = build(:user, document_vatid: user1.document_vatid.downcase)
    user3.valid?
    assert_includes user3.errors[:document_vatid], error_message

    # spaces
    user4 = build(:user, document_vatid: " #{user1.document_vatid.downcase} ")
    user4.valid?
    assert_includes user4.errors[:document_vatid], error_message

    user5 = build(:user)
    assert(user5.valid?)
  end

  test "accepts terms of service and age_restriction" do
    u = build(:user, terms_of_service: false, age_restriction: false)
    u.valid?
    assert_includes u.errors[:terms_of_service], "Debes aceptar las condiciones"
    assert_includes u.errors[:age_restriction], "Debes declarar que eres mayor de 16 años"
  end

  test "validates user is over 16 years old" do
    u = build(:user, born_at: Date.current - (16.years - 1.day))
    u.valid?
    assert_includes u.errors[:born_at], "Debes ser mayor de 16 años"
    u = build(:user, born_at: Date.civil(1888, 2, 1))
    u.valid?
    assert_includes u.errors[:born_at], "Debes ser mayor de 16 años"
    u = build(:user, born_at: Date.current - (16.years + 1.day))
    u.valid?
    assert(u.errors[:born_at], [])
  end

  test "validates document_type" do
    u = build(:user, document_type: 4)
    u.valid?
    assert_includes u.errors[:document_type], "Tipo de documento no válido"

    u = build(:user, document_type: 0)
    u.valid?
    assert_includes u.errors[:document_type], "Tipo de documento no válido"

    u = build(:user, document_type: 1)
    u.valid?
    assert_empty u.errors[:document_type]

    u = build(:user, document_type: 2)
    u.valid?
    assert_empty u.errors[:document_type]

    u = build(:user, document_type: 3)
    u.valid?
    assert_empty u.errors[:document_type]
  end

  test "doesn't generate redundant errors for document_type" do
    u = build(:user, document_type: '')
    u.valid?
    assert_equal ["Tu tipo de documento no puede estar en blanco"],
                 u.errors[:document_type]
  end

  test "doesn't generate redundante errors for postal_code" do
    u = User.new(country: 'ES', postal_code: '')
    u.valid?
    assert_equal ["Tu código postal no puede estar en blanco"],
                 u.errors[:postal_code]
  end

  test "validates Spanish postal code length" do
    u = User.new(country: 'ES', postal_code: '333333')
    u.valid?
    assert_equal ["El código postal debe ser un número de 5 cifras"],
                 u.errors[:postal_code]
  end

  test "validates Spanish postal code correctness" do
    u = User.new(country: 'ES', province: 'B', postal_code: '99999')
    u.valid?
    assert_equal ["El código postal no coincide con la provincia indicada"],
                 u.errors[:postal_code]
  end

  test ".full_name" do
    user = User.new(first_name: "Juan", last_name: "Perez")
    assert_equal("Juan Perez", user.full_name)
  end

  test ".full_address" do
    user = create(:user)
    assert_equal("C/ Inventada, 123, Madrid, Madrid, CP 28021, España", user.full_address)
  end

  test ".is_admin?" do
    user = create(:user)
    admin = create(:user, :admin)
    u = User.new
    assert_not u.is_admin?
    assert_not user.is_admin?
    assert admin.is_admin?
    new_admin = create(:user, document_type: 3, document_vatid: '2222222')
    assert_not new_admin.is_admin?
    new_admin.update_attribute(:admin, true)
    assert new_admin.is_admin?
  end

  test "phone accepts nil" do
    user = create(:user, phone: nil)
    assert user.valid?
  end

  test "phone rejects letters" do
    user = create(:user)
    user.phone = "aaaa"
    assert_not user.valid?
    assert_includes user.errors[:phone], "Revisa el formato de tu teléfono"
  end

  test "unconfirmed_phone accepts nil" do
    user = create(:user, unconfirmed_phone: nil)
    assert user.valid?
  end

  test "unconfirmed_phone rejects letters" do
    user = create(:user)
    user.unconfirmed_phone = "aaaa"
    assert_not user.valid?
    assert_includes user.errors[:unconfirmed_phone], "no es un número"
  end

  test ".validates_phone_format does not accept invalid phone numbers" do
    user = create(:user)
    user.phone = "12345"
    assert_not user.valid?
    assert_includes user.errors[:phone], "Revisa el formato de tu teléfono"
  end

  test ".validates_unconfirmed_phone does not accept invalid phone numbers from Spain" do
    user = create(:user, country: "ES")
    user.unconfirmed_phone = "12345"
    assert_not user.valid?
    assert_includes user.errors[:unconfirmed_phone], "Debes poner un teléfono móvil válido de España empezando por 6 o 7."
  end

  test ".validates_unconfirmed_phone does not accept invalid phone numbers from outside Spain" do
    user = create(:user, country: "BR", province: "RJ", town: nil)
    user.unconfirmed_phone = "12345"
    assert_not user.valid?
    assert_includes user.errors[:unconfirmed_phone], "Revisa el formato de tu teléfono"
  end

  test ".validates_unconfirmed_phone_format only accepts numbers starting with 6 or 7" do
    user = create(:user, unconfirmed_phone: "0034661234567")
    assert user.valid?
    user.unconfirmed_phone = "0034771234567"
    assert user.valid?
    user.unconfirmed_phone = "0034881234567"
    assert_not user.valid?
    assert_includes user.errors[:unconfirmed_phone], "Debes poner un teléfono móvil válido de España empezando por 6 o 7."
  end

  test ".validates_unconfirmed_phone_uniqueness" do
    with_verifications(online: true, presential: false) do
      phone = "0034612345678"
      sms_confirmed_user = create(:user, :confirmed_by_sms, phone: phone)
      user = create(:user)
      user.unconfirmed_phone = phone
      assert_not user.valid?
      assert_includes user.errors[:phone], "Ya hay alguien con ese número de teléfono"
    end
  end

  test ".can_change_phone? is false for recently added phones" do
    with_verifications(online: true) do
      user = create(:user, sms_confirmed_at: Time.zone.now - 1.month)
      assert_not user.can_change_phone?
    end
  end

  test ".can_change_phone? is true for not recently added phones" do
    with_verifications(online: true) do
      user = create(:user, sms_confirmed_at: Time.zone.now - 7.month)
      assert user.can_change_phone?
    end
  end

  test ".can_change_phone? is false for users without a phone" do
    with_verifications(online: true) do
      user = create(:user, sms_confirmed_at: nil)
      refute user.can_change_phone?
    end
  end

  test ".phone_normalize" do
    user = create(:user)
    assert_equal("0034661234567", user.phone_normalize("661234567", "ES"))
    assert_equal("0034661234567", user.phone_normalize("0034661234567", "ES"))
    assert_equal("0034661234567", user.phone_normalize("+34661234567", "ES"))
    assert_equal("0034661234567", user.phone_normalize("+34 661 23 45 67", "ES"))
    assert_equal("0034661234567", user.phone_normalize("0034661234567"))
    assert_equal("0034661234567", user.phone_normalize("+34661234567"))
    assert_equal("0034661234567", user.phone_normalize("+34 661 23 45 67"))
    assert_equal("0054661234567", user.phone_normalize("661234567", "AR"))
  end

  test ".phone_prefix" do
    user = create(:user)
    assert_equal "34", user.phone_prefix
    user.update_attribute(:country, "AR")
    assert_equal "54", user.phone_prefix
  end

  test ".phone_country_name" do
    user = create(:user)
    assert_equal "España", user.phone_country_name
    user.update_attribute(:phone, "005446311234")
    assert_equal "Argentina", user.phone_country_name
  end

  test ".phone_no_prefix" do
    user = create(:user, phone: "00346611111222")
    assert_equal "6611111222", user.phone_no_prefix
    user.update_attribute(:phone, "005446311234")
    assert_equal "46311234", user.phone_no_prefix
  end

  test ".generate_sms_token" do
    u = User.new
    token = u.generate_sms_token
    assert(!!(token.match(/^[[:alnum:]]+$/)))
  end

  test ".set_sms_token!" do
    u = create(:user)
    assert(u.sms_confirmation_token.nil?)
    u.set_sms_token!
    assert(u.sms_confirmation_token?)
  end

  test ".send_sms_token!" do
    user = create(:user)
    user.send_sms_token!
    # comprobamos que el SMS se haya enviado en los últimos 10 segundos
    assert(user.confirmation_sms_sent_at - Time.zone.now > -10)
  end

  test ".check_sms_token" do
    u = create(:user)
    u.set_sms_token!
    token = u.sms_confirmation_token
    assert(u.check_sms_token(token))
    assert_not(u.check_sms_token("LALALAAL"))
  end

  test ".check_sms_token bans user with spam data" do
    u = create(:user)
    u.set_sms_token!
    spam = create(:spam_filter)
    u.unconfirmed_phone = "0034661234567"
    u.phone = nil
    u.set_sms_token!
    token = u.sms_confirmation_token
    assert(u.check_sms_token(token))
    assert(u.banned?)
    comment = ActiveAdmin::Comment.last
    assert_equal u, comment.resource
    assert_equal "Usuario expulsado automáticamente por el filtro: #{spam.name}", comment.body
  end

  test ".document_type_name" do
    user = create(:user, document_type: 1)
    assert_equal "DNI", user.document_type_name
    user.update_attribute(:document_type, 2)
    assert_equal "NIE", user.document_type_name
    user.update_attribute(:document_type, 3)
    assert_equal "Pasaporte", user.document_type_name
  end

  test ".country_name works when country code is valid" do
    user = create(:user, country: "ES")
    assert_equal "España", user.country_name
    user.update_attribute(:country, "AR")
    assert_equal "Argentina", user.country_name
  end

  test ".country_name returns empty when country code is invalid" do
    user = create(:user)
    user.update_attribute(:country, "Testing")
    assert_equal "", user.country_name
  end

  test ".province_name works when province code is valid" do
    user = build(:user, country: "ES", province: "C", town: "m_15_006_3")
    assert_equal "A Coruña", user.province_name
    user = build(:user, country: "AR", province: "C", town: "m_15_006_3")
    assert_equal "Ciudad Autónoma de Buenos Aires", user.province_name
  end

  test ".province_name returns empty when province code is invalid" do
    user = build(:user, country: "AR", province: "Testing", town: "m_15_006_3")
    assert_equal "", user.province_name
    user = build(:user, country: "ES", province: "Patata", town: "m_28_079_6")
    assert_equal "", user.province_name
  end

  test ".province_name returns empty when country code is invalid" do
    user = build(:user, country: "España", province: "M", town: "m_28_079_6")
    assert_equal "", user.province_name
    user = build(:user, country: "España", province: "Madrid", town: "m_28_079_6")
    assert_equal "", user.province_name
  end

  test ".town_name returns empty when town code is invalid" do
    user = build(:user, country: "ES", province: "M", town: "mm_28_079_6")
    assert_equal "", user.town_name
  end

  test "scope .wants_newsletter works" do
    assert_difference -> { User.wants_newsletter.count }, 0 do
      create(:user, :newsletter_disabled)
    end

    assert_difference -> { User.wants_newsletter.count }, 1 do
      create(:user, :newsletter_enabled)
    end
  end

  test "act_as_paranoid" do
    user = create(:user)
    user.destroy
    assert_not User.exists?(user.id)
    assert User.with_deleted.exists?(user.id)
    user.restore
    assert User.exists?(user.id)
  end

  test "scope uniqueness with paranoia" do
    user = create(:user)
    user.destroy
    #  allow save after the user is destroyed but is with deleted_at
    user1 = build(:user, email: user.email, email_confirmation: user.email, document_vatid: user.document_vatid, phone: user.phone)
    assert user1.valid?
    user1.save

    # don't allow save after the user is created again (uniqueness is working)
    user2 = build(:user, email: user.email, document_vatid: user.document_vatid, phone: user.phone)
    assert_not user2.valid?
  end

  test "phone uniqueness works" do
    original = create(:user, phone: "0034661234567")
    dup = build(:user, phone: original.phone)
    assert_not dup.valid?
    assert dup.errors.include? :phone

    non_dup = build(:user, phone: "0034661234566")
    assert non_dup.valid?
  end

  test "uniqueness is not case sensitive" do
    user = create(:user)
    user2 = build(:user, document_vatid: user.document_vatid.downcase)
    assert_not user2.valid?
    user2 = build(:user, document_vatid: user.document_vatid.upcase)
    assert_not user2.valid?
  end

  test "password confirmation works" do
    user = build(:user, password_confirmation: '')
    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "Tu contraseña no coincide con la confirmación"

    user = build(:user, password_confirmation: "notthesamepassword")
    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "Tu contraseña no coincide con la confirmación"
  end

  test "email confirmation works" do
    user = build(:user, email_confirmation: '')
    assert_not user.valid?
    assert_includes user.errors[:email_confirmation], "Tu correo electrónico no coincide con la confirmación"

    user = build(:user, email_confirmation: "notthesameemail@gmail.com")
    assert_not user.valid?
    assert_includes user.errors[:email_confirmation], "Tu correo electrónico no coincide con la confirmación"
  end

  test "province_name works with all kind of profile data" do
    user = create(:user, country: "ES", province: "M", town: "m_28_079_6")
    assert_equal("Madrid", user.province_name)
    user = build(:user, country: "FR", province: "A", town: "m_28_079_6")
    assert_equal("Alsace", user.province_name)
    user = build(:user, country: "ES", province: "M", town: "Patata")
    assert_equal("Madrid", user.province_name)
  end

  test "country is a valid ISO code" do
    user = build(:user, country: "ES")
    assert user.valid?

    ["España", "", nil].each do |value|
      user = build(:user, country: value)
      assert_not user.valid?
      assert_includes user.errors[:country], "no está incluido en la lista"
    end
  end

  test "province_code works with invalid data" do
    user = create(:user)
    user.update_attributes(town: "Prueba", province: "tt")
    assert_equal("", user.province_code)
  end

  test "province is in the list of ISO codes for the country" do
    user = build(:user, country: "ES", province: "M")
    assert user.valid?

    user = build(:user, country: "ES", province: "Madrid")
    assert_not user.valid?
    assert_includes user.errors[:province], "no está incluido en la lista"
  end

  test "province is invalid unless blank if country has no regions" do
    user = build(:user, country: "MC", province: "Patata")
    assert_not user.valid?
    assert_includes user.errors[:province], "debe estar en blanco"

    user = build(:user, country: "MC", province: nil)
    user.valid?
    assert_empty user.errors[:province]
  end

  test "province is invalid unless blank if country is invalid" do
    user = build(:user, country: "España", province: "Madrid")
    assert_not user.valid?
    assert_includes user.errors[:province], "debe estar en blanco"

    user = build(:user, country: "España", province: nil)
    user.valid?
    assert_empty user.errors[:province]
  end

  test "vote_town_name, vote_province_name and vote_autonomy_name work" do
    user = create(:user)
    assert_equal("Madrid", user.vote_town_name)
    assert_equal("Madrid", user.vote_province_name)
    assert_equal("Comunidad de Madrid", user.vote_autonomy_name)
    user = create(:user, town: "m_01_001_4")
    assert_equal("Alegría-Dulantzi", user.vote_town_name)
    assert_equal("Araba/Álava", user.vote_province_name)
    # assert_equal("", user.vote_ca_name)

    user.update_attributes(country: "US", province: "AL", town: nil, vote_town: "m_01_001_4")
    assert_equal("Araba/Álava", user.vote_province_name)
    assert_equal("Alegría-Dulantzi", user.vote_town_name)

    user.update_attributes(country: "US", province: "AL", town: nil, vote_town: "m_01_")
    assert_equal("Araba/Álava", user.vote_province_name)
    assert_equal("", user.vote_town_name)

    user.update_attributes(country: "US", province: "AL", town: nil, vote_town: nil)
    assert_equal("", user.vote_province_name)
    assert_equal("", user.vote_town_name)
  end

  test "updates vote_town when town is changed and both are in Spain" do
    user = create(:user, town: "m_37_262_6")
    assert_equal user.town, user.vote_town, "User has changed his town (from Spain to Spain) and vote town didn't changed"
  end

  test "update vote_town when town is changed from foreign country to Spain" do
    user = create(:user)
    user2 = build(:user, :foreign)
    user2.save
    user2.country = "ES"
    user2.province = "SA"
    user2.town = "m_37_262_6"
    user2.save
    assert_equal user.town, user.vote_town, "User has changed his town (from foreign to Spain) and vote town didn't changed"
  end

  test "update vote_town when town is changed from Spain to a foreign country" do
    user = create(:user)
    user.update(country: "US", province: "AL", town: "Jefferson County")
    assert_not_equal user.town, user.vote_town, "User has changed his town (from Spain to a foreign country) and vote town changed"
  end

  test "main scopes work" do
    created = create(:user)
    deleted = create(:user, deleted_at: Time.zone.now)
    banned = create(:user, :banned)

    assert_equal [created], User.created
    assert_equal [deleted], User.deleted
    assert_equal [banned], User.banned
  end

  test "email confirmation scopes work" do
    create(:user, :banned)
    unconfirmed = create(:user, :unconfirmed_mail)
    confirmed = create(:user, :confirmed_mail)

    assert_equal [unconfirmed], User.unconfirmed_mail
    assert_equal [confirmed], User.confirmed_mail
  end

  test ".unconfirmed_phone work" do
    skip("TODO")
  end

  test "get_or_create_vote for elections work" do
    user = create(:user)
    e1 = create(:election)
    v1 = user.get_or_create_vote(e1.id)
    v2 = user.get_or_create_vote(e1.id)
    #  same election id, same scope, same voter_id
    assert_equal(v1.voter_id, v2.voter_id)

    #  same election id, different scope, different voter_id
    e2 = create(:election, :town)
    v3 = user.get_or_create_vote(e2.id)
    v4 = user.get_or_create_vote(e2.id)
    assert_equal(v3.voter_id, v4.voter_id)
    e2.election_locations.create(location: "010014", agora_version: 0)
    user.update_attribute(:town, "m_01_001_4")
    v5 = user.get_or_create_vote(e2.id)
    assert_not_equal v3.voter_id, v5.voter_id, "Diferente municipio de voto debería implicar diferente voter_id"
  end

  test "dest not change vote location to a user without old user" do
    with_blocked_change_location do
      new_user = create(:user, town: "m_03_003_6")
      new_user.apply_previous_user_vote_location
      assert_equal "m_03_003_6", new_user.vote_town, "New user vote location should not be changed"
    end
  end

  test ".catalonia_resident is inferred from location information" do
    madrilenian = build(:user, country: "ES", province: "B")
    assert_equal true, madrilenian.catalonia_resident

    barcelonian = build(:user, country: "ES", province: "M")
    assert_equal false, barcelonian.catalonia_resident

    carioca = build(:user, country: "BR", province: "RJ")
    assert_equal false, carioca.catalonia_resident
  end
end
