require_relative 'scaffold'

module AdaptiveConfiguration 
  class GroupBuilder

    attr_reader :definitions

    def initialize( &block )
      @definitions = {}
      self.instance_eval( &block ) if block_given?
    end

    def parameter( name, *args )
      name = name.to_sym 
      options = nil

      raise NameError, "The name '#{name}' is reserved and cannot be used for parameters." \
        if AdaptiveConfiguration::Scaffold.instance_methods.include?( name )

      if args.first.is_a?( ::Hash )
        # when called without type: parameter :stream, as: :streams
        options = args.first
      else
        # when called with type: parameter :stream, Boolean, as: :streams
        options = args[ 1 ] || {}
        options[ :type ] = args.first
      end
      
      @definitions[ name ] = options
    end

    def group( name, options = {}, &block )
      
      raise NameError, "The name '#{name}' is reserved and cannot be used for parameters." \
        if AdaptiveConfiguration::Scaffold.instance_methods.include?( name )
      
      builder = GroupBuilder.new
      builder.instance_eval( &block ) if block
      @definitions[ name ] = options.merge( { 
        type: :group, 
        definitions: builder.definitions 
      } )

    end

  end
end
