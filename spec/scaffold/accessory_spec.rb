require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  let( :definitions ) do
    {
      api_key:     { type: String },
      max_tokens:  { type: Integer, default: 100 }
    }
  end

  describe 'Accessors' do

    it 'allows reading values using []' do
      values = { api_key: 'test-key' }
      scaffold = build_scaffold( values, definitions: definitions )

      expect( scaffold[ :api_key ] ).to eq( 'test-key' )
      expect( scaffold[ :max_tokens ] ).to eq( 100 )
    end

    it 'allows setting values using []=' do
      scaffold = build_scaffold( definitions: definitions )

      scaffold[ :api_key ] = 'new-key'
      expect( scaffold[ :api_key ] ).to eq( 'new-key' )
    end

  end
end
