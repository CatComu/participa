if Rails.application.secrets.sms["provider"] == "esendex"
  Esendex.configure do |config|
    config.username = Rails.application.secrets.sms["esendex"]["username"]
    config.password = Rails.application.secrets.sms["esendex"]["password"]
    config.account_reference = Rails.application.secrets.sms["esendex"]["account_reference"]
  end
end

module SMS
  module Sender
    def self.send_message(to, code)
      case Rails.env
      when "staging", "production"
        body = "El teu codi d'activació per a Catalunya en Comú és #{code}"
        case Rails.application.secrets.sms["provider"]
        when "esendex"
          sms_esendex(to, body)
        when "somconnexio"
          sms_somconnexio(to, body)
        else
          Rails.logger.info "SMS NOT SEND"
          Rails.logger.info "Please configure provider on config/secrets.yml"
        end
      when "development", "test"
        Rails.logger.info "ACTIVATION CODE para #{to} == #{code}"
      else
        Rails.logger.info "ACTIVATION CODE para #{to} == #{code}"
      end
    end

    def self.sms_esendex to, body
      sms = Esendex::Account.new
      sms.send_message(
        from: "CatEnComu",
        to: to,
        body: body
      )
    end

    def self.sms_somconnexio to, body
      require 'savon'
      client = Savon.client(wsdl: Rails.application.secrets.sms["somconnexio"]["wsdl_url"])
      message = {
        user: Rails.application.secrets.sms["somconnexio"]["user"],
        pass: Rails.application.secrets.sms["somconnexio"]["pass"],
        src: Rails.application.secrets.sms["somconnexio"]["src"],
        dst: to,
        msg: body
      }
      client.call(:send_sms, message: message)
    end
  end
end
