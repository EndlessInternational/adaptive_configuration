require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'Initialization' do

    it 'initializes with given definitions and values' do
      definitions = {
        api_key:     { type: String },
        max_tokens:  { type: Integer, default: 100 }
      }
      values = { api_key: 'test-key' }

      context = AdaptiveConfiguration::Context.new(
        values, converters: converters, definitions: definitions
      )

      expect( context[ :api_key ] ).to eq( 'test-key' )
      expect( context[ :max_tokens ] ).to eq( 100 )
    end

    it 'initializes with given definitions and values when groups are present' do
      definitions = {
        api_key: { type: String },
        chat_options: {
          type: :group,
          definitions: {
            max_tokens: { type: Integer, default: 100 }
          }
        }
      }
      values = { api_key: 'test-key', chat_options: { max_tokens: 1024 } }

      context = AdaptiveConfiguration::Context.new(
        values, converters: converters, definitions: definitions
      )

      expect( context[ :api_key ] ).to eq( 'test-key' )
      expect( context[ :chat_options ][ :max_tokens ] ).to eq( 1024 )
    end

    it 'initializes with given values when aliases are present' do
      definitions = {
        api_key:     { type: String, as: :apiKey },
        max_tokens:  { type: Integer, default: 100, as: :maxTokens }
      }
      values = { api_key: 'test-key' }

      context = AdaptiveConfiguration::Context.new(
        values, converters: converters, definitions: definitions
      )

      expect( context[ :apiKey ] ).to eq( 'test-key' )
      expect( context[ :maxTokens ] ).to eq( 100 )
    end

    it 'initializes with given values when groups and aliases are present' do
      definitions = {
        api_key: { type: String, as: :apiKey },
        chat_options: {
          type: :group,
          as: :chatOptions,
          definitions: {
            max_tokens: { type: Integer, default: 100, as: :maxTokens }
          }
        }
      }
      values = { api_key: 'test-key', chat_options: { max_tokens: 1024 } }

      context = AdaptiveConfiguration::Context.new(
        values, converters: converters, definitions: definitions
      )

      expect( context[ :apiKey ] ).to eq( 'test-key' )
      expect( context[ :chatOptions ][ :maxTokens ] ).to eq( 1024 )
    end

    it 'sets default values when values are not provided' do
      definitions = {
        timeout:  { type: Integer, default: 30 },
        retries:  { type: Integer, default: 3 }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context[ :timeout ] ).to eq( 30 )
      expect( context[ :retries ] ).to eq( 3 )
    end

    it 'initializes nested contexts for group types' do
      definitions = {
        database: {
          type: :group,
          definitions: {
            host: { type: String, default: 'localhost' },
            port: { type: Integer, default: 5432 }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context[ :database ] ).to be_a( AdaptiveConfiguration::Context )
      expect( context[ :database ][ :host ] ).to eq( 'localhost' )
      expect( context[ :database ][ :port ] ).to eq( 5432 )
    end

  end

end
