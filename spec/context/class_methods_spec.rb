RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'Class Methods and Attributes' do

    it 'returns correct class' do
      definitions = {}

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.class ).to eq( AdaptiveConfiguration::Context )
    end

    it 'checks instance of correctly' do
      definitions = {}

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.is_a?( AdaptiveConfiguration::Context ) ).to be true
    end

  end

end
