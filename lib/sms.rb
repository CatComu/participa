module SMS
  module Sender
    def self.send_message(to, code)
      case Rails.env
      when "staging", "production"
        sms = Esendex::Account.new
        sms.send_message(
          from: "CatEnComu",
          to: to,
          body: "El teu codi d'activació per a Catalunya en Comú és #{code}"
        )
      when "development", "test"
        Rails.logger.info "ACTIVATION CODE para #{to} == #{code}"
      else
        Rails.logger.info "ACTIVATION CODE para #{to} == #{code}"
      end
    end
  end
end
