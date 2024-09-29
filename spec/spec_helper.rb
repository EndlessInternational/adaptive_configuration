require 'rspec'
require 'adaptive_configuration'

RSpec.configure do | config |

  config.expect_with :rspec do | expectations |
    expectations.syntax = :expect
  end

  config.mock_with :rspec do | mocks |
    mocks.syntax = :expect
  end

  # allows using "describe" instead of "RSpec.describe"
  config.expose_dsl_globally = true

end
