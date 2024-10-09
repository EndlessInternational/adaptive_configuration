require_relative 'group_builder'
require_relative 'context'

# types must be included to support conversation
require 'time'
require 'date'
require 'uri'

module AdaptiveConfiguration 
  class Builder < GroupBuilder

    DEFAULT_CONVERTERS = {

      Array       => ->( v ) { Array( v ) },
      Date        => ->( v ) { v.respond_to?( :to_date ) ? v.to_date : Date.parse( v.to_s ) },
      Time        => ->( v ) { v.respond_to?( :to_time ) ? v.to_time : Time.parse( v.to_s ) },
      URI         => ->( v ) { URI.parse( v.to_s ) },
      String      => ->( v ) { String( v ) },
      Symbol      => ->( v ) { v.respond_to?( :to_sym ) ? v.to_sym : nil },
      Rational    => ->( v ) { Rational( v ) },
      Float       => ->( v ) { Float( v ) },
      Integer     => ->( v ) { Integer( v ) },
      TrueClass   => ->( v ) { 
        case v
        when Numeric 
          v.nonzero? ? true : nil 
        else
          v.to_s.match(  /\A\s*(true|yes)\s*\z/i ) ? true : nil 
        end
      },
      FalseClass  => ->( v ) {  
        case v
        when Numeric 
          v.zero? ? false : nil 
        else
          v.to_s.match(  /\A\s*(false|no)\s*\z/i ) ? false : nil 
        end
      }

    }

    def initialize
      super
      @converters = DEFAULT_CONVERTERS.dup 
    end

    def convert( klass, &block )
      @converters[ klass ] = block 
    end

    def build( values = nil, &block )
      context = AdaptiveConfiguration::Context.new( 
        values,
        converters: @converters, 
        definitions: @definitions 
      )
      context.instance_eval( &block ) if block
      context
    end

    def build!( values = nil, &block )
      context = self.build( values, &block )
      context.validate!
      context
    end

  end
end
