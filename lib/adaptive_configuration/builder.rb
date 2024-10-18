require_relative 'properties_builder'
require_relative 'scaffold'

# types must be included to support coersion
require 'time'
require 'date'
require 'uri'

module AdaptiveConfiguration 
  class Builder < PropertiesBuilder

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
      scaffold = AdaptiveConfiguration::Scaffold.new( 
        values,
        converters: @converters, 
        definitions: @definitions 
      )
      scaffold.instance_eval( &block ) if block
      scaffold.to_h
    end

    def build!( values = nil, &block )
      scaffold = AdaptiveConfiguration::Scaffold.new( 
        values,
        converters: @converters, 
        definitions: @definitions 
      )
      scaffold.instance_eval( &block ) if block
      result = scaffold.to_h 
      validate!( result )
      result 
    end

    def validate!( values )
      traverse_and_validate_values( values, definitions: @definitions ) { | error | 
        raise error 
      } 
    end
    
    def validate( values )
      errors = []
      traverse_and_validate_values( values, definitions: @definitions ) { | error | 
        errors << error 
      }
      errors
    end

    def valid?( values )
      traverse_and_validate_values( values, definitions: @definitions ) { 
        return false 
      }
      return true
    end

  protected

    def value_matches_types?( value, types )
      type_match = false  
      Array( types ).each do | type |
        type_match = value.is_a?( type )
        break if type_match
      end
      type_match
    end 

    def traverse_and_validate_values( values, definitions:, path: nil, options: nil, &block )  

      path.chomp( '/' ) if path
      unless values.is_a?( Hash )
        raise ArgumentError, "The values must always be a Hash." 
      end

      definitions.each do | key, definition |

        name = definition[ :as ] || key 
        value = values[ name ]

        if definition[ :required ] && 
           ( !value || ( value.respond_to?( :empty ) && value.empty? ) )
          block.call( RequiredOptionError.new( path: path, key: key ) )
        elsif definition[ :in ] && !definition[ :in ].include?( value )
          block.call( 
            InOptionError.new( path: path, key: key, option: definition[ :in ], value: value )
          )
        elsif !definition[ :default_assigned ] && !value.nil?
          unless definition[ :array ]
            if definition[ :type ] == Object
              traverse_and_validate_values( 
                values[ name ],
                definitions: definition[ :definitions ],
                path: "#{ ( path || '' ) + ( path ? '/' : '' ) + key.to_s }", 
                &block 
              )
            else     
              if definition[ :type ] && value && !definition[ :default_assigned ]
                unless value_matches_types?( value, definition[ :type ] )
                  block.call( IncompatibleTypeError.new( 
                    path: path, key: key, type: definition[ :type ], value: value
                  ) )
                end          
              end
            end
          else 
            if definition[ :type ] == Object
              groups = Array( value )
              groups.each do | group |
                traverse_and_validate_values(
                  group, 
                  definitions: definition[ :definitions ],
                  path: "#{ ( path || '' ) + ( path ? '/' : '' ) + key.to_s }", 
                  &block 
                )
              end
            else
              if definition[ :type ] && !definition[ :default_assigned ]
                value_array = Array( value )
                value_array.each do | v | 
                  unless value_matches_types?( v, definition[ :type ] )
                    block.call( IncompatibleTypeError.new( 
                      path: path, key: key, type: definition[ :type ], value: v
                    ) )
                  end
                end  
              end
            end
          end
        end

      end
      
      nil

    end

  end
end
