require 'debug'

module AdaptiveConfiguration
  
  class Error < StandardError; end


  class IncompatibleTypeError < Error

    attr_reader :keypath 
    attr_reader :key 
    attr_reader :type

    def initialize( path: nil, key:, type:, value: )
      
      path = path ? path.to_s.chomp( '/' ) : nil 
      @key = key
      @keypath = path ? ( path + '/' + @key.to_s ) : @key.to_s 
      @type = type
      type_text = @type.respond_to?( :join ) ? type.join( ', ' ) : type

      super( "The parameter '#{@keypath}' expects #{type_text} but received incompatible #{value.class.name}." )
    end

  end

  class RequirementUnmetError < Error

    attr_reader :keypath 
    attr_reader :key 

    def initialize( path: nil, key:  )
      path = path ? path.chomp( '/' ) : nil 
      @key = key
      @keypath = path ? ( path + '/' + @key.to_s ) : key.to_s    
      super( "The parameter #{@keypath} is required." )
    end

  end

end