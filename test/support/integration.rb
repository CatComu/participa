require 'capybara/rails'
require 'capybara/minitest'

module ActionDispatch
  class IntegrationTest
    include Warden::Test::Helpers
    include Capybara::DSL
    include Capybara::Minitest::Assertions

    teardown do
      Capybara.reset_sessions!
    end
  end
end

class JsFeatureTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  teardown do
    Capybara.use_default_driver
  end
end
