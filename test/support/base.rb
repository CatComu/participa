require 'minitest/hooks/test'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Minitest::Hooks

  def with_verifications(presential: true, sms: true)
    prev_presential = Features.presential_verifications?
    prev_sms = Features.online_verifications?

    Rails.application.secrets.features["verification_presencial"] = presential
    Rails.application.secrets.features["verification_sms"] = sms

    yield
  ensure
    Rails.application.secrets.features["verification_presencial"] = prev_presential
    Rails.application.secrets.features["verification_sms"] = prev_sms
  end
end
