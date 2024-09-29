require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'String Representation' do

    it 'returns a string representation using inspect' do
      definitions = {
        api_key: { type: String }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.api_key 'test-key'

      expect( context.inspect ).to eq( '{:api_key=>"test-key"}' )
    end

  end

end
