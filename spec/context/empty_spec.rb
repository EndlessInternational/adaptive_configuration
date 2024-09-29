RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'empty? Method' do

    it 'returns true when context has no values' do
      definitions = {
        api_key: { type: String }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.empty? ).to be true
    end

    it 'returns false when context has values' do
      definitions = {
        api_key: { type: String }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.api_key 'test-key'

      expect( context.empty? ).to be false
    end

  end

end
