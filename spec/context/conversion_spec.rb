RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'paramter type conversion' do

    it 'converts string values to Integer when type is Integer' do
      definitions = {
        count: { type: Integer }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.count '42'

      expect( context[ :count ] ).to eq( 42 )
    end

    it 'raises error when string cannot be converted to Integer' do
      definitions = {
        count: { type: Integer }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.count 'not a number'
      }.to raise_error( TypeError, /expects a value of type Integer/ )
    end

    it 'converts string values to Float when type is Float' do
      definitions = {
        price: { type: Float }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.price '19.99'

      expect( context[ :price ] ).to eq( 19.99 )
    end

    it 'converts string values to Date when type is Date' do
      definitions = {
        start_date: { type: Date }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.start_date '2023-01-01'

      expect( context[ :start_date ] ).to eq( Date.new( 2023, 1, 1 ) )
    end

    it 'raises error when string cannot be converted to Date' do
      definitions = {
        start_date: { type: Date }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.start_date 'invalid date'
      }.to raise_error( TypeError )
    end

    it 'converts string values to Time when type is Time' do
      definitions = {
        start_time: { type: Time }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.start_time '2023-01-01 12:34:56'

      expect( context[ :start_time ] ).to eq( Time.parse( '2023-01-01 12:34:56' ) )
    end

    it 'converts string values to URI when type is URI' do
      definitions = {
        website: { type: URI }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.website 'http://example.com'

      expect( context[ :website ] ).to eq( URI.parse( 'http://example.com' ) )
    end

    it 'raises error when string cannot be converted to URI' do
      definitions = {
        website: { type: URI }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.website 'invalid uri ://'
      }.to raise_error( TypeError )
    end

    it 'converts values to TrueClass when type is TrueClass' do
      definitions = {
        enabled: { type: TrueClass }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.enabled 'yes'

      expect( context[ :enabled ] ).to eq( true )

      context.enabled 'true'

      expect( context[ :enabled ] ).to eq( true )
    end

    it 'converts values to FalseClass when type is FalseClass' do
      definitions = {
        disabled: { type: FalseClass }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.disabled 'no'

      expect( context[ :disabled ] ).to eq( false )

      context.disabled 'false'

      expect( context[ :disabled ] ).to eq( false )
    end

    it 'allows custom converters to be added' do

      class UpcaseString < String
        def initialize( string )
          super( string.upcase )
        end
      end

      builder = AdaptiveConfiguration::Builder.new
      builder.convert( UpcaseString ) { | v | UpcaseString.new( v ) }
      builder.parameter :name, UpcaseString

      context = builder.build!
      context.name 'john doe'

      expect( context[ :name ] ).to be_a( UpcaseString )
      expect( context[ :name ].to_s ).to eq( 'JOHN DOE' )
    end

    it 'applies conversions in array parameters' do
      definitions = {
        numbers: { type: Integer, array: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.numbers [ '1', '2', '3' ]

      expect( context[ :numbers ] ).to eq( [ 1, 2, 3 ] )
    end

    it 'raises error when conversion fails in array parameters' do
      definitions = {
        numbers: { type: Integer, array: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.numbers [ '1', 'two', '3' ]
      }.to raise_error( TypeError, /expects a value of type Integer/ )
    end

    it 'applies conversions in nested contexts' do
      definitions = {
        user: {
          type: :group,
          definitions: {
            age: { type: Integer }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.user do
        age '30'
      end

      expect( context[ :user ][ :age ] ).to eq( 30 )
    end

    it 'raises error when conversion fails in nested contexts' do
      definitions = {
        user: {
          type: :group,
          definitions: {
            age: { type: Integer }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.user do
          age 'thirty'
        end
      }.to raise_error( TypeError, /expects a value of type Integer/ )
    end

    it 'applies conversions using multiple types' do
      builder = AdaptiveConfiguration::Builder.new
      builder.convert( [ Integer, String ] ) { | v | Integer( v ) rescue v.to_s }
      builder.parameter :value, [ Integer, String ]

      context = builder.build!
      context.value '42'

      expect( context[ :value ] ).to eq( 42 )

      context.value 'not a number'

      expect( context[ :value ] ).to eq( 'not a number' )
    end

    it 'supports converting values with multiple possible types' do
      definitions = {
        flexible_param: { type: [ Integer, String ] }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.flexible_param '123'
      expect( context[ :flexible_param ] ).to eq( '123' )

      context.flexible_param 123
      expect( context[ :flexible_param ] ).to eq( 123 )

    end

    it 'raises error when value cannot be converted to any of the specified types' do
      definitions = {
        flexible_param: { type: [ Integer, Date ] }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.flexible_param 'abc'
      }.to raise_error( TypeError, /expects a value of type Integer, Date/ )
    end

  end

end
