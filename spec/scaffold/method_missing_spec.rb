require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  let( :definitions ) do
    {
      api_key:  { type: String },
      options:  {
        type: :group,
        definitions: {
          model: { type: String }
        }
      }
    }
  end

  describe 'method Missing and dynamic methods' do

    it 'allows setting and getting parameters using method calls' do
      scaffold = build_scaffold( definitions: definitions )

      scaffold.api_key 'test-key'
      result = scaffold.to_h
      expect( result[ :api_key ] ).to eq( 'test-key' )
    end

    it 'supports nested groups using method calls' do
      scaffold = build_scaffold( definitions: definitions )

      scaffold.options do
        model 'test-model'
      end

      result = scaffold.to_h
      expect( result[ :options ][ :model ] ).to eq( 'test-model' )
    end

    it 'raises NoMethodError for undefined methods' do
      scaffold = build_scaffold( definitions: definitions )

      expect {
        scaffold.undefined_method
      }.to raise_error( NoMethodError )
    end

    it 'responds to defined methods' do
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.respond_to?( :api_key ) ).to be true
      expect( scaffold.respond_to?( :options ) ).to be true
      expect( scaffold.respond_to?( :undefined_method ) ).to be false
    end

  end

end
