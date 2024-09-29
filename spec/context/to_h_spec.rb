require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'to_h Method' do

    it 'converts context to a hash' do
      definitions = {
        api_key:  { type: String },
        options:  {
          type: :group,
          definitions: {
            model: { type: String }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.api_key 'test-key'
      context.options do
        model 'test-model'
      end

      expected_hash = {
        api_key: 'test-key',
        options: {
          model: 'test-model'
        }
      }

      expect( context.to_h ).to eq( expected_hash )
    end

    it 'handles empty contexts' do
      definitions = {}

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.to_h ).to eq( {} )
    end

    it 'handles nested contexts with arrays' do
      definitions = {
        messages: {
          type: :group,
          array: true,
          definitions: {
            role:    { type: String },
            content: { type: String }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      context.messages do
        role 'user'
        content 'Hello!'
      end

      context.messages do
        role 'assistant'
        content 'Hi there!'
      end

      expected_hash = {
        messages: [
          { role: 'user', content: 'Hello!' },
          { role: 'assistant', content: 'Hi there!' }
        ]
      }

      expect( context.to_h ).to eq( expected_hash )
    end

  end

end
