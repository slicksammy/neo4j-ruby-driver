require 'dotenv'
Dotenv.load

require "bundler/setup"
require "neo4j/driver"
require 'support/driver_helper'
require 'support/neo4j_cleaner'
require 'rspec/its'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include DriverHelper::Helper
  # config.include Neo4jCleaner
  include DriverHelper::Helper
  include Neo4jCleaner
  config.before(:suite) { clean }
  config.after(:suite) { driver.close }
  config.around(:each) do |example|
    cleaning do
      example.run
    end
  end
end
