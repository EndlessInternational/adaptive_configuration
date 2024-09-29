require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  let( :definitions ) do
    {
      api_key:     { type: String },
      max_tokens:  { type: Integer, default: 100 }
    }
  end

  describe 'Accessors' do

    it 'allows reading values using []' do
      values = { api_key: 'test-key' }
      context = AdaptiveConfiguration::Context.new(
        values, converters: converters, definitions: definitions
      )

      expect( context[ :api_key ] ).to eq( 'test-key' )
      expect( context[ :max_tokens ] ).to eq( 100 )
    end

    it 'allows setting values using []=' do
      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context[ :api_key ] = 'new-key'
      expect( context[ :api_key ] ).to eq( 'new-key' )
    end

    it 'allows iterating over values using each' do
      values = { api_key: 'test-key', max_tokens: 200 }
      context = AdaptiveConfiguration::Context.new(
        values, converters: converters, definitions: definitions
      )

      collected = {}
      context.each do | key, value |
        collected[ key ] = value
      end
      expect( collected ).to eq( { api_key: 'test-key', max_tokens: 200 } )
    end

  end

end
