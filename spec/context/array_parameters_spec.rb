RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'array parameters' do

    it 'handles array parameters correctly' do
      definitions = {
        tags: { type: String, array: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.tags [ 'tag1', 'tag2' ]

      expect( context[ :tags ] ).to eq( [ 'tag1', 'tag2' ] )
    end

    it 'appends to array parameters when called multiple times' do
      definitions = {
        tags: { type: String, array: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.tags [ 'tag1' ]
      context.tags [ 'tag2', 'tag3' ]

      expect( context[ :tags ] ).to eq( [ 'tag1', 'tag2', 'tag3' ] )
    end

    it 'validates types within array parameters' do
      definitions = {
        numbers: { type: Integer, array: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.numbers [ 1, 'two', 3 ]
      }.to raise_error( TypeError, /expects a value of type Integer/ )
    end

  end

end
