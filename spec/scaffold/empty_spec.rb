require 'spec_helper.rb'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'empty? Method' do

    it 'returns true when context has no values' do
      definitions = {
        api_key: { type: String }
      }
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.empty? ).to be true
    end

    it 'returns false when context has values' do
      definitions = {
        api_key: { type: String }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.api_key 'test-key'

      expect( scaffold.empty? ).to be false
    end

  end

end
