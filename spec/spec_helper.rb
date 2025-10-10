require 'rspec'
require_relative '../app/helpers/schema_helper'

# Define CURRENT_DOMAIN constant for tests
CURRENT_DOMAIN = 'rozarioflowers.ru' unless defined?(CURRENT_DOMAIN)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
