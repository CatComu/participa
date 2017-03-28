module Participa
  module Test
    module VerificationHelpers
      def pending_verification_message
        if Features.presential_verifications?
          "¡Sólo te queda una última verificación por hacer!"
        else
          "Por seguridad, debes confirmar tu teléfono."
        end
      end

      def pending_verification_path
        if Features.presential_verifications?
          root_path(locale: "es")
        else
          sms_validator_step1_path(locale: "es")
        end
      end
    end
  end
end
