module AdaptiveConfiguration
  class Context < BasicObject

    def initialize( values = nil, definitions:, converters: )

      values = values ? values.transform_keys( &:to_sym ) : {}
      
      @converters = converters&.dup 
      @definitions = definitions&.dup 
      @values = {}
      
      @definitions.each do | key, definition |
        name = definition[ :as ] || key 
        if definition[ :type ] == :group
          context = Context.new( 
            values[ key ] || {},
            converters: @converters, definitions: definition[ :definitions ], 
          )
          @values[ name ] = context unless context.empty?
        elsif definition.key?( :default )
          @values[ name ] = definition[ :array ] ? 
            ::Kernel.method( :Array ).call( definition[ :default ] ) : 
            definition[ :default ]
          # note: this is needed to know when an array paramter which was initially assigned
          #       to a default should be replaced rather than appended
          definition[ :default_assigned ] = true
        end
        self.__send__( key, values[ key ] ) if values[ key ]
      end

    end

    def []( key )
      @values[ key ]
    end

    def []=( key, value )
      @values[ key ] = value
    end

    def each( &block )
      @values.each( &block )
    end

    def merge( hash )
      self.to_h.merge( hash )
    end

    def empty?
      @values.empty?
    end

    def to_h
      recursive_to_h = ->( object ) do
        case object
        when ::AdaptiveConfiguration::Context
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

    def to_yaml
      self.to_h.to_yaml
    end

    def inspect
      @values.inspect
    end

    def class
      ::AdaptiveConfiguration::Context
    end

    def is_a?( klass )
      klass == ::AdaptiveConfiguration::Context || klass == ::BasicObject
    end

    alias :kind_of? :is_a?

    def method_missing( method, *args, &block )

      if @definitions.key?( method )

        definition = @definitions[ method ]
        name = definition[ :as ] || method

        unless definition[ :array ] 
          if definition[ :type ] == :group
            context = 
              @values[ name ] || 
              Context.new( converters: @converters, definitions: definition[ :definitions ] )
            context.instance_eval( &block ) if block
            @values[ name ] = context 
          else
            value = args.first
            value = _convert_value!( definition[ :type ], method, value ) if definition[ :type ] 
            @values[ name ] = value
          end
        else
          @values[ name ] = definition[ :default_assigned ] ? 
            ::Array.new : 
            @values[ name ] || ::Array.new
          if definition[ :type ] == :group
            context = Context.new( converters: @converters, definitions: definition[ :definitions ] )
            context.instance_eval( &block ) if block
            @values[ name ] << context 
          else
            values = ::Kernel.method( :Array ).call( args.first )
            if type = definition[ :type ]
              values = values.map { | v | _convert_value!( type, method, v ) } 
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

    private; def _convert_value!( klass, key, value )
      return value unless klass && value

      types =::Kernel.method( :Array ).call( klass ) 
      result = nil

      types.each do | type |
        result = 
          ( ( value.respond_to?( :is_a? ) && value.is_a?( type ) ) ? value : nil ) ||
          @converters[ klass ].call( value ) rescue nil 
        break if result 
      end

      if result.nil?
        types_names = types.map( &:name ).join( ', ' )
        ::Kernel.raise ::TypeError, <<~TEXT.gsub( /\s+/, ' ' ).strip
          The key #{key} expects a value of type #{types_names} but received an 
          incompatible #{value.class.name}.
        TEXT
      end

      result
    end

  end
end    
