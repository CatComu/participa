require 'savon' 

module SMS
  module Sender
    def self.send_message(dst, code)
      case Rails.env
      when "staging", "production"
        client = Savon.client(wsdl: Rails.application.secrets.sms["wsdl_url"])
        message = {
          user: Rails.application.secrets.sms["user"],
          pass: Rails.application.secrets.sms["pass"],
          src: Rails.application.secrets.sms["src"],
          dst: dst, 
          msg: "El teu codi d'activació per a Un País en Comú és #{code}"
        }
        response = client.call(:send_sms, message: message)
        Rails.logger.debug response.to_s
      when "development", "test"
        Rails.logger.info "ACTIVATION CODE para #{dst} == #{code}"
      else
        Rails.logger.info "ACTIVATION CODE para #{dst} == #{code}"
      end
    end
  end
end
