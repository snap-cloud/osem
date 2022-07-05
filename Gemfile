# frozen_string_literal: true

source 'https://rubygems.org'

ruby ENV['TRAVIS_RUBY_VERSION'] || '~>2.6'

# rails-assets requires >= 1.8.4
if Gem::Version.new(Bundler::VERSION) < Gem::Version.new('1.8.4')
  abort "Bundler version >= 1.8.4 is required"
end

gem 'rails', '~> 5.2'

# Use Puma as the app server
gem 'puma', '~> 5.6'

# respond_to methods have been extracted to the responders gem
# http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#responders
gem 'responders', '~> 2.0'

# as supported databases
gem 'pg'
gem 'pghero'
# gem 'pg_query', '>= 0.9.0'

# for tracking data changes
gem 'paper_trail'

# for upload management
gem 'carrierwave'
gem 'carrierwave-bombshelter'
gem 'mini_magick'
# for uploading images to the cloud
gem 'cloudinary'

# for internationalizing
gem 'rails-i18n'

# as authentification framework
gem 'devise'
gem 'devise_ichain_authenticatable'

gem 'omniauth'
gem 'omniauth-discourse'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-openid'

# Bot-filtering
gem 'recaptcha', require: 'recaptcha/rails'

# as authorization framework
gem 'cancancan'

# for roles
gem 'rolify'

# to show flash messages from ajax requests
gem 'unobtrusive_flash', '>=3'

# as state machine
gem 'transitions', :require => %w( transitions active_record/transitions )

# for comments
gem 'acts_as_commentable_with_threading'
gem 'awesome_nested_set'

# as templating language
gem 'haml-rails'

# for stylesheets
gem 'sass-rails', '>= 4.0.2'

# as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# as the front-end framework
gem 'autoprefixer-rails'
gem 'bootstrap-sass', '~> 3.4.0'
gem 'cocoon'
gem 'formtastic', '~> 3.1.5'
gem 'formtastic-bootstrap'

# as the JavaScript library
# TODO: Consolidate with the rails-assets below or move to webpack...
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0.1'

# for languages validation
gem 'iso-639'

# frontend javascripts
source 'https://rails-assets.org' do
  # for placeholder images
  gem 'rails-assets-holderjs'
  # for formating dates
  gem 'rails-assets-date.format'
  # for or parsing, validating, manipulating, and formatting dates
  gem 'rails-assets-momentjs'
  # for smooth scrolling
  gem 'rails-assets-jquery-smooth-scroll'
  # as color picker
  gem 'rails-assets-spectrum'
  # for color manipulation
  gem 'rails-assets-tinycolor'
  # for drawing triangle backgrounds
  gem 'rails-assets-trianglify'
  # for scroll way points
  gem 'rails-assets-waypoints'
  # for markdown editors
  gem 'rails-assets-bootstrap-markdown'
  # for select with icon
  gem 'rails-assets-bootstrap-select'
  gem 'rails-assets-markdown'
  gem 'rails-assets-to-markdown', '~> 3'
end

# as date picker
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'

# for switch checkboxes
gem 'bootstrap-switch-rails', '~> 3.0.0'

# data tables
gem 'ajax-datatables-rails'
gem 'jquery-datatables'

# for charts
gem 'chartkick'

# for displaying maps
gem 'leaflet-rails'

# for user avatars
gem 'gravtastic'

# for country selects
gem 'country_select'

# as PDF generator
gem 'prawn-qrcode'
gem 'prawn-rails'

# for QR code generation
gem 'rqrcode'

# to render XLS spreadsheets
gem 'caxlsx'
gem 'caxlsx_rails'

# Application Monitoring
gem 'sentry-delayed_job'
gem 'sentry-rails'
gem 'sentry-ruby'

# to make links faster
gem 'turbolinks'

# for JSON serialization of our API
gem 'active_model_serializers'

# as icon font
gem 'font-awesome-rails'

# for markdown
gem 'redcarpet'

# for visitor tracking
gem 'piwik_analytics', '~> 1.0.1'

# for recurring jobs
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'whenever', :require => false

# to run scripts
gem 'daemons'

# to encapsulate money in objects
gem 'money-rails'

# for lists
gem 'acts_as_list'

# for parsing OEmbed data
gem 'ruby-oembed'

# for setting app configuration in the environment
gem 'dotenv-rails'

# configurable toggles for functionality
# https://github.com/mgsnova/feature
gem 'feature'

# For countable.js
gem "countable-rails"

# Both are not in a group as we use it also for rake data:demo
# for fake data
gem 'faker'
# for seeds
gem 'factory_bot_rails'

# for integrating Stripe payment gateway
gem 'stripe'

# Provides Sprockets implementation for Rails Asset Pipeline
gem 'sprockets-rails'

# for multiple speakers select on proposal/event forms
gem 'selectize-rails'

# n+1 query logging
gem 'bullet'
# For collecting performance data
gem 'skylight'

gem 'nokogiri'

# memcached binary connector
gem 'dalli', require: false
# Redis Cache
gem 'redis'

gem 'icalendar'

# for making external requests easier
gem 'httparty'

# pagination
gem 'pagy', '<4.0'

# Use guard and spring for testing in development
group :development do
  # to launch specs when files are modified
  gem 'guard-rspec'
  gem 'spring-commands-rspec'
  # to open mails
  gem 'letter_opener'
  # view mail at /letter_opener/
  gem 'letter_opener_web'
  # as deployment system
  gem 'mina'
  # as debugger on error pages
  gem 'web-console'
  # prepend models with db schema
  gem 'annotate'
end

group :test do
  # as test framework
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'cucumber-rails-training-wheels' # basic imperative step defs like "Then I should see..."
  gem 'database_cleaner'
  gem 'geckodriver-helper'
  gem 'rspec-rails'
  gem 'webdrivers'
  # for measuring test coverage
  gem 'simplecov-cobertura'
  # for describing models
  gem 'shoulda-matchers', require: false
  # for stubing/mocking models
  gem 'rspec-activemodel-mocks'
  # to freeze time
  gem 'timecop'
  # for mocking external requests
  gem 'webmock'
  # for mocking Stripe responses in tests
  gem 'stripe-ruby-mock'
  # For validating JSON schemas
  gem 'json-schema'
  # For using 'assigns' in tests
  gem 'rails-controller-testing'
  # For managing the environment
  gem 'climate_control'
  # For PDFs
  gem 'pdf-inspector', require: "pdf/inspector"
end

group :development, :test, :linters do
  # as debugger
  gem 'byebug'
  gem 'pry'
  gem 'pry-byebug'

  # Linters and static analysis.
  gem 'haml-lint', require: false
  gem 'pronto', require: false
  gem 'pronto-flay', require: false
  gem 'pronto-haml', require: false
  gem 'pronto-rubocop', require: false
  gem 'rubocop-faker', require: false
  gem 'rubocop-rspec', require: false
end

group :development, :test do
  # as development/test database
  gem 'sqlite3'
end
