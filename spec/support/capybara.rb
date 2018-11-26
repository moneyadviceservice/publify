# frozen_string_literal: true

require 'capybara/poltergeist'

Capybara.app = Rack::Builder.parse_file('config.ru').first
Capybara.javascript_driver = :poltergeist
