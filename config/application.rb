require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Participa
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.exceptions_app = self.routes
    config.time_zone = 'Madrid'
    config.i18n.default_locale = :ca
    config.i18n.available_locales = [ :es, :ca ]
    config.i18n.fallbacks = [:es, :en] # https://github.com/jim/carmen-rails/issues/13 
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'carmen', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'carmen', 'es', '*.{rb,yml}').to_s]
    config.action_mailer.default_url_options = { host: Rails.application.secrets.host }

     # participa overrides start
    folder = Rails.application.secrets.organization["folder"]

    config.assets.paths << Rails.root.join("vendor", "overrides", folder, "app", "assets", "javascripts")
    config.i18n.load_path += Dir[Rails.root.join('vendor', 'overrides', folder, 'config', 'locales', '*.{rb,yml}').to_s]

    config.generators do |g|
      g.test_framework :test_unit, fixture: true
    end

    config.to_prepare do
      Devise::Mailer.layout "email"
    end
  end
end

Rails.application.routes.default_url_options[:host] = Rails.application.secrets.host

require 'add_unique_month_to_dates'
