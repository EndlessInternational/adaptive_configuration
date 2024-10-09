require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'paramter type coersion' do

    it 'coerces string values to Integer when type is Integer' do
      definitions = {
        count: { type: Integer }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.count '42'

      expect( context[ :count ] ).to eq( 42 )
      expect( context[ :count ] ).to be_a( Integer )
    end

    it 'coerces string values to Float when type is Float' do
      definitions = {
        price: { type: Float }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.price '19.99'

      expect( context[ :price ] ).to eq( 19.99 )
      expect( context[ :price ] ).to be_a( Float )
    end

    it 'coerces string values to Date when type is Date' do
      definitions = {
        start_date: { type: Date }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.start_date '2023-01-01'

      expect( context[ :start_date ] ).to eq( Date.new( 2023, 1, 1 ) )
      expect( context[ :start_date ] ).to be_a( Date )

    end

    it 'coerces string values to Time when type is Time' do
      definitions = {
        start_time: { type: Time }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.start_time '2023-01-01 12:34:56'

      expect( context[ :start_time ] ).to eq( Time.parse( '2023-01-01 12:34:56' ) )
      expect( context[ :start_time ] ).to be_a( Time )
    end

    it 'coerces string values to URI when type is URI' do
      definitions = {
        website: { type: URI }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.website 'http://example.com'

      expect( context[ :website ] ).to eq( URI.parse( 'http://example.com' ) )
      expect( context[ :website ] ).to be_a( URI )

    end

    it 'coerces values to TrueClass class when compatible value is given' do
      definitions = {
        enabled: { type: [ TrueClass, FalseClass ] }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.enabled 'yes'

      expect( context[ :enabled ] ).to eq( true )

      context.enabled 'true'

      expect( context[ :enabled ] ).to eq( true )
    end

    it 'coerces values to FalseClass when compatible value is given' do
      definitions = {
        disabled: { type: [ TrueClass, FalseClass ] }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.disabled 'no'
      expect( context[ :disabled ] ).to eq( false )
      context.disabled 'false'
      expect( context[ :disabled ] ).to eq( false )
    end

    it 'coerces values to Symbol when compatible value is given' do 
      definitions = {
        strategy: { type: Symbol }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions 
      )

      context.strategy 'fight'
      expect( context[ :strategy ] ).to be_a( Symbol )
      expect( context[ :strategy ] ).to eq :fight 
      context.strategy 'flight'
      expect( context[ :strategy ] ).to be_a( Symbol )
      expect( context[ :strategy ] ).to eq :flight 
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

    it 'coerces array parameters' do
      definitions = {
        numbers: { type: Integer, array: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.numbers [ '1', '2', '3' ]

      expect( context[ :numbers ] ).to eq( [ 1, 2, 3 ] )
    end

    it 'coerces nested contexts' do
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
      expect( context[ :user ][ :age ] ).to be_a( Integer )

    end

    it 'coerces using multiple types' do
      
      builder = AdaptiveConfiguration::Builder.new
      builder.parameter :value, [ Integer, String ]

      context = builder.build!
      context.value '42'

      expect( context[ :value ] ).to eq( '42' )

      context.value 'not a number'

      expect( context[ :value ] ).to eq( 'not a number' )
    end

    it 'supports coercion with multiple possible types' do
      definitions = {
        flexible_param: { type: [ Integer, String ] }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.flexible_param '123'
      expect( context[ :flexible_param ] ).to be_a( String )
      expect( context[ :flexible_param ] ).to eq( '123' )

      context.flexible_param 123
      expect( context[ :flexible_param ] ).to be_a( Integer )
      expect( context[ :flexible_param ] ).to eq( 123 )

    end

  end

end
