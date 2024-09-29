RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'respond_to? Method' do

    it 'responds to defined parameters' do
      definitions = {
        api_key: { type: String }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.respond_to?( :api_key ) ).to be true
    end

    it 'does not respond to undefined parameters' do
      definitions = {
        api_key: { type: String }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.respond_to?( :undefined_param ) ).to be false
    end

    it 'responds to methods defined in BasicObject' do
      definitions = {}

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.respond_to?( :__send__ ) ).to be true
      expect( context.respond_to?( :__id__ ) ).to be true
    end

  end

end
