ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'simplecov'
require 'webmock/minitest'

require 'support/database_cleaner'

require 'support/base'
require 'support/controllers'
require 'support/integration'

require 'support/assertions'

SimpleCov.start
WebMock.disable_net_connect!(allow_localhost: true)
Warden.test_mode!

def with_blocked_change_location
  begin
    Rails.application.secrets.users["allows_location_change"] = false
    yield
  ensure
    Rails.application.secrets.users["allows_location_change"] = true
  end
end

require 'capybara/poltergeist'

# Poltergeist customization
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, url_whitelist: ['127.0.0.1'])
end

Capybara.javascript_driver = :poltergeist
Capybara.asset_host = 'http://localhost:3000'
