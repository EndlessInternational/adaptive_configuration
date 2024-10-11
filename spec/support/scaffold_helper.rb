module ScaffoldHelper

  DEFAULT_CONVERTERS = AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup

  def build_scaffold( values = nil, definitions: )   
    AdaptiveConfiguration::Scaffold.new( 
      values, 
      converters: DEFAULT_CONVERTERS, 
      definitions: definitions 
    )
  end

end

RSpec.configure do | config |
  config.include ScaffoldHelper
end

