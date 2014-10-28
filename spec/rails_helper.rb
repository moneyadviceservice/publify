# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl'
require 'rexml/document'
FactoryGirl.find_definitions

class EmailNotify
  class << self
    alias_method :real_send_user_create_notification, :send_user_create_notification
    def send_user_create_notification(_user); end
  end
end

class ActionView::TestCase::TestController
  include Rails.application.routes.url_helpers
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

module RSpec
  module Core
    module Hooks
      class HookCollection
        def find_hooks_for(group)
          self.class.new(select { |hook| hook.options_apply?(group) })
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  config.infer_spec_type_from_file_location!

  # shortcuts for factory_girl to use: create / build / build_stubbed
  config.include FactoryGirl::Syntax::Methods
end

def define_spec_public_cache_directory
  ActionController::Base.page_cache_directory = File.join(Rails.root, 'spec', 'public')
  unless File.exist? ActionController::Base.page_cache_directory
    FileUtils.mkdir_p ActionController::Base.page_cache_directory
  end
end

def path_for_file_in_spec_public_cache_directory(file)
  define_spec_public_cache_directory
  File.join(ActionController::Base.page_cache_directory, file)
end

def create_file_in_spec_public_cache_directory(file)
  file_path = path_for_file_in_spec_public_cache_directory(file)
  File.open(file_path, 'a').close
  file_path
end

# TODO: Clean up use of these Test::Unit style expectations
def assert_xml(xml)
  expect do
    assert REXML::Document.new(xml)
  end.not_to raise_error
end

def assert_atom10(feed, count)
  doc = Nokogiri::XML.parse(feed)
  root = doc.css(':root').first
  expect(root.name).to eq('feed')
  expect(root.namespace.href).to eq('http://www.w3.org/2005/Atom')
  expect(root.css('entry').count).to eq(count)
end

def assert_rss20(feed, count)
  doc = Nokogiri::XML.parse(feed)
  root = doc.css(':root').first
  expect(root.name).to eq('rss')
  expect(root['version']).to eq('2.0')
  expect(root.css('channel item').count).to eq(count)
end

def stub_full_article(time = Time.now)
  author = FactoryGirl.build_stubbed(User, name: 'User Name')
  text_filter = FactoryGirl.build(:textile)

  a = FactoryGirl.build_stubbed(Article, published_at: time, user: author,
                 created_at: time, updated_at: time,
                 title: 'Foo Bar', permalink: 'foo-bar',
                 guid: time.hash)
  allow(a).to receive(:published_comments) { [] }
  allow(a).to receive(:resources) { [FactoryGirl.build(:resource)] }
  allow(a).to receive(:tags) { [FactoryGirl.build(:tag)] }
  allow(a).to receive(:text_filter) { text_filter }
  a
end

# This test now has optional support for validating the generated RSS feeds.
# Since Ruby doesn't have a RSS/Atom validator, I'm using the Python source
# for http://feedvalidator.org and calling it via 'system'.
#
# To install the validator, download the source from
# http://sourceforge.net/cvs/?group_id=99943
# Then copy src/feedvalidator and src/rdflib into a Python lib directory.
# Finally, copy src/demo.py into your path as 'feedvalidator', make it executable,
# and change the first line to something like '#!/usr/bin/python'.

if $validator_installed.nil?
  $validator_installed = false
  begin
    IO.popen('feedvalidator 2> /dev/null', 'r') do |pipe|
      if pipe.read =~ %r{Validating http://www.intertwingly.net/blog/index.}
        puts 'Using locally installed Python feed validator'
        $validator_installed = true
      end
    end
  rescue
    nil
  end
end

def assert_feedvalidator(rss, todo = nil)
  unless $validator_installed
    puts 'Not validating feed because no validator (feedvalidator in python) is installed'
    return
  end

  begin
    file = Tempfile.new('publify-feed-test')
    filename = file.path
    file.write(rss)
    file.close

    messages = ''

    IO.popen("feedvalidator file://#{filename}") do |pipe|
      messages = pipe.read
    end

    okay, messages = parse_validator_messages(messages)

    if todo && !ENV['RUN_TODO_TESTS']
      assert !okay, messages + "\nTest unexpectedly passed!\nFeed text:\n" + rss
    else
      assert okay, messages + "\nFeed text:\n" + rss
    end
  end
end

def parse_validator_messages(message)
  messages = message.split(/\n/).reject do |m|
    m =~ /Feeds should not be served with the "text\/plain" media type/ ||
      m =~ /Self reference doesn't match document location/
  end

  if messages.size > 1
    [false, messages.join("\n")]
  else
    [true, '']
  end
end
