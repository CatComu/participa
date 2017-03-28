require 'minitest/hooks/test'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Minitest::Hooks

  def with_features(features, &block)
    prev = {}

    features.each do |name, value|
      prev[name] = Rails.application.secrets.features[name.to_s]
      Rails.application.secrets.features[name.to_s] = value
    end

    Rails.application.reload_routes!

    yield

  ensure
    features.each do |name, value|
      Rails.application.secrets.features[name.to_s] = prev[name]
    end

    Rails.application.reload_routes!
  end

  def with_verifications(presential: true, online: true)
    prev_presential = Features.presential_verifications?
    prev_online = Features.online_verifications?

    Rails.application.secrets.features["verification_presencial"] = presential
    Rails.application.secrets.features["verification_sms"] = online

    yield
  ensure
    Rails.application.secrets.features["verification_presencial"] = prev_presential
    Rails.application.secrets.features["verification_sms"] = prev_online
  end
end
