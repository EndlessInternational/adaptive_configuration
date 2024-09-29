require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  let( :definitions ) do
    {
      api_key:  { type: String },
      options:  {
        type: :group,
        definitions: {
          model: { type: String }
        }
      }
    }
  end

  describe 'method Missing and dynamic methods' do

    it 'allows setting and getting parameters using method calls' do
      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.api_key 'test-key'
      expect( context[ :api_key ] ).to eq( 'test-key' )
    end

    it 'supports nested groups using method calls' do
      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.options do
        model 'test-model'
      end

      expect( context[ :options ][ :model ] ).to eq( 'test-model' )
    end

    it 'raises NoMethodError for undefined methods' do
      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.undefined_method
      }.to raise_error( NoMethodError )
    end

    it 'responds to defined methods' do
      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.respond_to?( :api_key ) ).to be true
      expect( context.respond_to?( :options ) ).to be true
      expect( context.respond_to?( :undefined_method ) ).to be false
    end

  end

end
