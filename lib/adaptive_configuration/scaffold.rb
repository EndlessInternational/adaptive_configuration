module AdaptiveConfiguration
  class Scaffold < BasicObject

    include ::PP::ObjectMixin if defined?( ::PP )

    attr_reader :errors

    def initialize( values = nil, definitions:, converters: )
      raise ArgumentError, 'The Scaffold initialitization attributes must be a Hash pr Hash-like.'\
        unless values.nil? || ( values.respond_to?( :[] ) && values.respond_to?( :key? ) )

      @converters = converters&.dup 
      @definitions = definitions&.dup 
      @values = {}
      @errors = []
      
      @definitions.each do | key, definition |
        name = definition[ :as ] || key 
        if definition.key?( :default )
          self.__send__( key, definition[ :default ] )
          # note: this is needed to know when an array parameter which was initially assigned
          #       to a default should be replaced rather than appended
          definition[ :default_assigned ] = true
        end
        self.__send__( key, values[ key ] ) if values && values.key?( key ) 
      end

    end

    def nil?
      false  
    end

    def empty?
      @values.empty?
    end

    def to_h
      recursive_to_h = ->( object ) do
        case object
        when ::NilClass
          nil
        when ::AdaptiveConfiguration::Scaffold
          recursive_to_h.call( object.to_h )
        when ::Hash
          object.transform_values { | value | recursive_to_h.call( value ) }
        when ::Array
          object.map { | element | recursive_to_h.call( element ) }
        else
          object.respond_to?( :to_h ) ? object.to_h : object
        end
      end

      recursive_to_h.call( @values )
    end

    def to_s
      inspect
    end

    def inspect
      { values: @values, definitions: @definitions }.inspect 
    end

    if defined?( ::PP )
      def pretty_print( pp )
        pp.pp( { values: @values, definitions: @definitions } )
      end
    end

    def class
      ::AdaptiveConfiguration::Scaffold
    end

    def is_a?( klass )
      klass == ::AdaptiveConfiguration::Scaffold || klass == ::BasicObject
    end

    alias :kind_of? :is_a?

    def method_missing( method, *args, &block )
    
      if @definitions.key?( method )
        definition = @definitions[ method ]
        name = definition[ :as ] || method

        unless definition[ :array ] 
          if definition[ :type ] == ::Object
            value = args.first 
            context = @values[ name ]
            if context.nil? || value  
              context = 
                Scaffold.new( 
                  value,
                  converters: @converters, 
                  definitions: definition[ :definitions ] 
                )
            end
            context.instance_eval( &block ) if block
            @values[ name ] = context 
          else 
            value = args.first
            new_value = definition[ :type ] ? __coerce_value( definition[ :type ], value ) : value
            @values[ name ] = new_value.nil? ? value : new_value
          end
        else
          @values[ name ] = definition[ :default_assigned ] ? 
            ::Array.new : 
            @values[ name ] || ::Array.new
          if definition[ :type ] == ::Object
            values = [ args.first ].flatten
            values = values.map do | v |
              context = Scaffold.new( 
                v,
                converters: @converters, 
                definitions: definition[ :definitions ] 
              )
              context.instance_eval( &block ) if block
              context
            end
            @values[ name ].concat( values ) 
          else
            values = ::Kernel.method( :Array ).call( args.first )
            if type = definition[ :type ]
              values = values.map do | v | 
                new_value = __coerce_value( type, v )
                new_value.nil? ? v : new_value
              end 
            end
            @values[ name ].concat( values )
          end
        end

        definition[ :default_assigned ] = false
        @values[ name ]
      else
        super
      end

    end

    def respond_to?( method, include_private = false )
      @definitions.key?( method ) || self.class.instance_methods.include?( method ) 
    end

    def respond_to_missing?( method, include_private = false )
      @definitions.key?( method ) || self.class.instance_methods.include?( method ) 
    end

  protected 
    
    def __coerce_value( types, value )

      return value unless types && !value.nil?

      types = ::Kernel.method( :Array ).call( types ) 
      result = nil

      if value.respond_to?( :is_a? )
        types.each do | type |
          result = value.is_a?( type ) ? value : nil 
          break unless result.nil?
        end
      end

      if result.nil?
        types.each do | type |
          result = @converters[ type ].call( value ) rescue nil
          break unless result.nil?
        end
      end

      result
    end

  end
end    
