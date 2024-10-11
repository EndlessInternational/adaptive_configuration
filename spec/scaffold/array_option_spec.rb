require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe ':array option' do

    it 'handles array parameters correctly' do
      definitions = {
        tags: { type: String, array: true }
      }

      scaffold = build_scaffold( definitions: definitions )
      scaffold.tags [ 'tag1', 'tag2' ]

      result = scaffold.to_h
      expect( result[ :tags ] ).to eq( [ 'tag1', 'tag2' ] )
    end

    it 'appends to array parameters when called multiple times' do
      definitions = {
        tags: { type: String, array: true }
      }

      scaffold = build_scaffold( definitions: definitions )
      scaffold.tags [ 'tag1' ]
      scaffold.tags [ 'tag2', 'tag3' ]

      result = scaffold.to_h
      expect( result[ :tags ] ).to eq( [ 'tag1', 'tag2', 'tag3' ] )
    end

  end

end
