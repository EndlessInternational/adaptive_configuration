require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do
  describe 'type coersion' do

    it 'coerces string values to Integer when type is Integer' do
      definitions = {
        count: { type: Integer }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.count '42'

      result = scaffold.to_h
      expect( result[ :count ] ).to eq( 42 )
      expect( result[ :count ] ).to be_a( Integer )
    end

    it 'coerces string values to Float when type is Float' do
      definitions = {
        price: { type: Float }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.price '19.99'

      result = scaffold.to_h
      expect( result[ :price ] ).to eq( 19.99 )
      expect( result[ :price ] ).to be_a( Float )
    end

    it 'coerces string values to Date when type is Date' do
      definitions = {
        start_date: { type: Date }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.start_date '2023-01-01'

      result = scaffold.to_h
      expect( result[ :start_date ] ).to eq( Date.new( 2023, 1, 1 ) )
      expect( result[ :start_date ] ).to be_a( Date )
    end

    it 'coerces string values to Time when type is Time' do
      definitions = {
        start_time: { type: Time }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.start_time '2023-01-01 12:34:56'

      result = scaffold.to_h
      expect( result[ :start_time ] ).to eq( Time.parse( '2023-01-01 12:34:56' ) )
      expect( result[ :start_time ] ).to be_a( Time )
    end

    it 'coerces string values to URI when type is URI' do
      definitions = {
        website: { type: URI }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.website 'http://example.com'

      result = scaffold.to_h
      expect( result[ :website ] ).to eq( URI.parse( 'http://example.com' ) )
      expect( result[ :website ] ).to be_a( URI )
    end

    it 'coerces values to TrueClass class when compatible value is given' do
      definitions = {
        enabled: { type: [ TrueClass, FalseClass ] }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.enabled 'yes'

      result = scaffold.to_h
      expect( result[ :enabled ] ).to eq( true )

      scaffold.enabled 'true'

      result = scaffold.to_h
      expect( result[ :enabled ] ).to eq( true )
    end

    it 'coerces values to FalseClass when compatible value is given' do
      definitions = {
        disabled: { type: [ TrueClass, FalseClass ] }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.disabled 'no'

      result = scaffold.to_h
      expect( result[ :disabled ] ).to eq( false )

      scaffold.disabled 'false'

      result = scaffold.to_h
      expect( result[ :disabled ] ).to eq( false )
    end

    it 'coerces values to Symbol when compatible value is given' do 
      definitions = {
        strategy: { type: Symbol }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.strategy 'fight'

      result = scaffold.to_h
      expect( result[ :strategy ] ).to be_a( Symbol )
      expect( result[ :strategy ] ).to eq :fight 

      scaffold.strategy 'flight'

      result = scaffold.to_h
      expect( result[ :strategy ] ).to be_a( Symbol )
      expect( result[ :strategy ] ).to eq :flight 
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

      result = builder.build! do
        name 'john doe'
      end 

      expect( result[ :name ] ).to be_a( UpcaseString )
      expect( result[ :name ].to_s ).to eq( 'JOHN DOE' )
    end

    it 'coerces array parameters' do
      definitions = {
        numbers: { type: Integer, array: true }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.numbers [ '1', '2', '3' ]

      result = scaffold.to_h
      expect( result[ :numbers ] ).to eq( [ 1, 2, 3 ] )
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
      scaffold = build_scaffold( definitions: definitions )

      scaffold.user do
        age '30'
      end

      result = scaffold.to_h
      expect( result[ :user ][ :age ] ).to eq( 30 )
      expect( result[ :user ][ :age ] ).to be_a( Integer )
    end

    it 'coerces using multiple types' do
      builder = AdaptiveConfiguration::Builder.new
      builder.parameter :value, [ Integer, String ]

      result = builder.build! do
        value '42'
      end

      expect( result[ :value ] ).to eq( '42' )
  
      result = builder.build do 
        value 'not a number'
      end

      expect( result[ :value ] ).to eq( 'not a number' )
    end

    it 'supports coercion with multiple possible types' do
      definitions = {
        flexible_param: { type: [ Integer, String ] }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.flexible_param '123'
      
      result = scaffold.to_h
      expect( result[ :flexible_param ] ).to be_a( String )
      expect( result[ :flexible_param ] ).to eq( '123' )

      scaffold.flexible_param 123
      
      result = scaffold.to_h
      expect( result[ :flexible_param ] ).to be_a( Integer )
      expect( result[ :flexible_param ] ).to eq( 123 )
    end

  end
end
