require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'Initialization' do

    it 'initializes with given definitions and values' do
      definitions = {
        api_key:     { type: String },
        max_tokens:  { type: Integer, default: 100 }
      }
      values = { api_key: 'test-key' }
      scaffold = build_scaffold( values, definitions: definitions )

      result = scaffold.to_h
      expect( result[ :api_key ] ).to eq( 'test-key' )
      expect( result[ :max_tokens ] ).to eq( 100 )
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
      scaffold = build_scaffold( values, definitions: definitions )

      result = scaffold.to_h
      expect( result[ :api_key ] ).to eq( 'test-key' )
      expect( result[ :chat_options ][ :max_tokens ] ).to eq( 1024 )
    end

    it 'initializes with given values when aliases are present' do
      definitions = {
        api_key:     { type: String, as: :apiKey },
        max_tokens:  { type: Integer, default: 100, as: :maxTokens }
      }
      values = { api_key: 'test-key' }
      scaffold = build_scaffold( values, definitions: definitions )

      result = scaffold.to_h
      expect( result[ :apiKey ] ).to eq( 'test-key' )
      expect( result[ :maxTokens ] ).to eq( 100 )
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
      scaffold = build_scaffold( values, definitions: definitions )

      result = scaffold.to_h
      expect( result[ :apiKey ] ).to eq( 'test-key' )
      expect( result[ :chatOptions ][ :maxTokens ] ).to eq( 1024 )
    end

    it 'sets default values when values are not provided' do
      definitions = {
        timeout:  { type: Integer, default: 30 },
        retries:  { type: Integer, default: 3 }
      }
      scaffold = build_scaffold( definitions: definitions )

      result = scaffold.to_h
      expect( result[ :timeout ] ).to eq( 30 )
      expect( result[ :retries ] ).to eq( 3 )
    end

    it 'initializes nested contexts for group types' do
      definitions = {
        database: {
          type: :group,
          default: {},
          definitions: {
            host: { type: String, default: 'localhost' },
            port: { type: Integer, default: 5432 }
          }
        }
      }
      scaffold = build_scaffold( definitions: definitions )

      result = scaffold.to_h
      expect( result[ :database ] ).to be_a( Hash )
      expect( result[ :database ][ :host ] ).to eq( 'localhost' )
      expect( result[ :database ][ :port ] ).to eq( 5432 )
    end

  end

end
