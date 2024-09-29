require_relative 'builder'

module AdaptiveConfiguration
	module Configurable

    def configuration( &block )
      @configuration_builder ||= AdaptiveConfiguration::Builder.new 
      @configuration_builder.instance_eval( &block )
      @configuration_builder
    end

    def configure( attributes = nil, &block )
      raise RuntimeError, "The adapter configuration has not been defined." \
        if @configuration_builder.nil?
      configuration = @configuration_builder.build!( attributes, &block )
    end

  end
end

