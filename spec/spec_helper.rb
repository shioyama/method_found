$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'method_found'

require 'pry-byebug'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
