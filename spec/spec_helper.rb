ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'
require 'rspec/autorun'
require 'codeclimate-test-reporter'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|

  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = false

  config.order = '1'

  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

end

require_relative './capybara_helper'
require_relative './evaluation_helper'

RSpec.configure do |config|
  config.before(:each) do
    unless example.metadata[:clean]
      create(:organization,
             name: 'test',
             book: create(:book, name: 'test', slug: 'mumuki/mumuki-the-book')).switch!
    end
  end

  config.after(:each) do
    Organization.current = nil
  end
end


RSpec::Matchers.define :json_eq do |expected_json_hash|
  match do |actual_json|
    expected_json_hash.with_indifferent_access == ActiveSupport::JSON.decode(actual_json)
  end
end

CodeClimate::TestReporter.start
