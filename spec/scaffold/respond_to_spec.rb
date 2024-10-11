require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'respond_to? Method' do

    it 'responds to defined parameters' do
      definitions = {
        api_key: { type: String }
      }
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.respond_to?( :api_key ) ).to be true
    end

    it 'does not respond to undefined parameters' do
      definitions = {
        api_key: { type: String }
      }
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.respond_to?( :undefined_param ) ).to be false
    end

    it 'responds to methods defined in BasicObject' do
      definitions = {}
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.respond_to?( :__send__ ) ).to be true
      expect( scaffold.respond_to?( :__id__ ) ).to be true
    end

  end

end
