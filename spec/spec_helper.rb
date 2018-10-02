require 'bundler/setup'
require 'pviewer'
require 'rspec/json_expectations'
require 'support/utilities'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Disable InfluxDB logs
  # InfluxDB::Logging.logger = false # used to smoke tests
end
