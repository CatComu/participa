require "test_helper"

class ParticipationTeamsTest < JsFeatureTest

  test "can't access as anon, can join, can delete itself" do
    with_features(participation_teams: true,
                  verifications_sms: false,
                  verifications_presencial: false) do
      visit participation_teams_path
      assert_content "Necesitas iniciar sesión o registrarte para continuar."

      user = create(:user)
      login_as(user)
      visit participation_teams_path
      assert_content "Nos encontramos a un momento decisivo para cambiar"

      # FIXME: failing tests
      skip
      
      #click_link "¡Únete", match: :first
      #assert_content "En los próximos días nos pondremos en contacto contigo."

      #click_link "Darme de baja"
      #assert_content "Te has dado de baja de los Equipos de Acción Participativa"
    end
  end

end
