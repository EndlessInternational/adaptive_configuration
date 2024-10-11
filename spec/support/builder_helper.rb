module BuilderHelper

  def construct_builder( &block )   
    AdaptiveConfiguration::Builder.new( &block )
  end

end

RSpec.configure do | config |
  config.include BuilderHelper
end

