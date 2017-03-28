source 'https://rubygems.org'

ruby RUBY_VERSION

# @todo Revisit the warnings fixed by this in Bundler 2, I guess they will be
# fixed and this won't be needed
#
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")

  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'sprockets-rails'

gem 'pg'
gem 'airbrake', group: :production

gem 'devise'
gem 'cancancan', '~> 1.9'
gem 'bootstrap-sass'
gem 'formtastic'
gem 'formtastic-bootstrap'
gem 'spanish_vat_validators', github: 'deivid-rodriguez/spanish_vat_validators',
                              branch: 'rails_5_deprecations'
gem 'simple_captcha2', require: 'simple_captcha'
gem 'carmen-rails'
gem 'savon', '~> 2.11.0'

#
# @todo: activeadmin/activeadmin#4477 broke our "new verification center" page,
# so I'm pinning AA to the commit prior to that change. Report the bug to AA.
#
gem 'activeadmin', github: 'activeadmin', ref: 'e7c3d8cfc7ec3aeaf6893588068dbcd9bd2744f7'
gem 'active_skin'

gem 'resque', github: 'resque/resque', require: 'resque/server'
gem 'sinatra', '>= 2.0.0.beta2'

gem 'aws-ses', '~> 0.6.0', :require => 'aws/ses'
gem 'kaminari'
gem 'pushmeup'
gem 'date_validator'
gem 'phone'
gem 'iban-tools'
gem 'paper_trail'
gem 'ffi-icu'
gem 'unicode'
gem 'rack-openid'
gem 'ruby-openid'
gem 'rake-progressbar'
gem 'rails_autolink'
gem 'flag_shih_tzu'
gem 'enumerize'
gem 'wicked_pdf'
gem "font-awesome-rails"
gem 'friendly_id', '~> 5.1.0'
gem 'auto_html', '~> 1.6'
gem "paranoia"
gem 'cocoon'
gem 'paperclip'
gem 'validate_url'
gem 'norma43', github: 'podemos-info/norma43'
gem 'sepa_king' # for generate SEPA XML files

group :development, :test do
  gem 'capistrano', '~> 3.4'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'factory_girl_rails'
  gem 'byebug'
  gem 'rubocop'
  gem 'ruby-prof'
  gem 'simplecov'
end

group :test do
  gem 'capybara', '~> 2.13'
  gem 'transactional_capybara'
  gem 'poltergeist'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'minitest-hooks'
end

gem 'webmock', group: :development

source 'https://rails-assets.org' do
  gem 'rails-assets-flatpickr-calendar'
  gem 'rails-assets-leaflet'
  gem 'rails-assets-img-viewerjs'
end
