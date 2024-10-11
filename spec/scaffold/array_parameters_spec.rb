require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'array parameters' do

    it 'handles array parameters correctly' do
      definitions = {
        tags: { type: String, array: true }
      }

      scaffold = build_scaffold( definitions: definitions )
      scaffold.tags [ 'tag1', 'tag2' ]

      expect( scaffold[ :tags ] ).to eq( [ 'tag1', 'tag2' ] )
    end

    it 'appends to array parameters when called multiple times' do
      definitions = {
        tags: { type: String, array: true }
      }

      scaffold = build_scaffold( definitions: definitions )
      scaffold.tags [ 'tag1' ]
      scaffold.tags [ 'tag2', 'tag3' ]

      expect( scaffold[ :tags ] ).to eq( [ 'tag1', 'tag2', 'tag3' ] )
    end

    it 'validates types within array parameters' do
      definitions = {
        numbers: { type: Integer, array: true }
      }
      scaffold = build_scaffold( definitions: definitions )

      expect {
        scaffold.numbers [ 1, 'two', 3 ]
        scaffold.validate!
      }.to raise_error( 
        AdaptiveConfiguration::IncompatibleTypeError, 
        /expects Integer but received incompatible String/ 
      )
    end

  end

end
