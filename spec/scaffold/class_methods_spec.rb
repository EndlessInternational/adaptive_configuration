require 'spec_helper.rb'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'Class Methods and Attributes' do

    it 'returns correct class' do
      definitions = {}
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.class ).to eq( AdaptiveConfiguration::Scaffold )
    end

    it 'checks instance of correctly' do
      definitions = {}
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.is_a?( AdaptiveConfiguration::Scaffold ) ).to be true
    end

  end

end
