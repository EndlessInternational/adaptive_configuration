require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'to_h method' do

    it 'converts scaffold to a hash' do
      definitions = {
        api_key:  { type: String },
        options:  {
          type: Object,
          definitions: {
            model: { type: String }
          }
        }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.api_key 'test-key'
      scaffold.options do
        model 'test-model'
      end

      expected_hash = {
        api_key: 'test-key',
        options: {
          model: 'test-model'
        }
      }

      expect( scaffold.to_h ).to eq( expected_hash )
    end

    it 'handles empty scaffolds' do
      definitions = {}
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.to_h ).to eq( {} )
    end

    it 'handles nested scaffolds with arrays' do
      definitions = {
        messages: {
          type: Object,
          array: true,
          definitions: {
            role:    { type: String },
            content: { type: String }
          }
        }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.messages do
        role 'user'
        content 'Hello!'
      end

      scaffold.messages do
        role 'assistant'
        content 'Hi there!'
      end

      expected_hash = {
        messages: [
          { role: 'user', content: 'Hello!' },
          { role: 'assistant', content: 'Hi there!' }
        ]
      }

      expect( scaffold.to_h ).to eq( expected_hash )
    end

  end

end
