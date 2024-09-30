require 'spec_helper'
require 'debug'

RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe ':required option' do

    it 'the context is invalid when required parameters are not set' do

      definitions = {
        api_key: { type: String, required: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.valid? ).to eq( false )
      expect( context.errors ).not_to be_empty

      error = context.errors.first
      expect( error ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
      expect( error.key ).to eq( :api_key )
      expect( error.keypath ).to eq( 'api_key' )

      expect {
        context.validate!
      }.to raise_error( AdaptiveConfiguration::RequirementUnmetError, /required/ )
    
    end

    it 'the context is valid when required parameters are set' do

      definitions = {
        api_key: { type: String, required: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.api_key '123'

      expect( context.valid? ).to eq( true )

      expect {
        context.validate!
      }.not_to raise_error

    end

    it 'the context is invalid when required array parameters are not set' do

      definitions = {
        words: { type: String, required: true, array: true  }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context.valid? ).to eq( false )
      expect( context.errors ).not_to be_empty

      error = context.errors.first
      expect( error ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
      expect( error.key ).to eq( :words )
      expect( error.keypath ).to eq( 'words' )

      expect {
        context.validate!
      }.to raise_error( AdaptiveConfiguration::RequirementUnmetError, /required/ )
    
    end

    it 'the context is valid when required array parameters are set' do

      definitions = {
        words: { type: String, required: true, array: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.words 'one'
      expect( context.valid? ).to eq( true )

      context.words 'two'
      expect( context.valid? ).to eq( true )

      expect {
        context.validate!
      }.not_to raise_error

    end

    it 'the context is invalid when required groups are not present' do

      context = AdaptiveConfiguration::Context.new(
        converters: converters, 
        definitions: {
          book: {
            type: :group,
            required: true,
            converters: converters, 
            definitions: {}
          } 
        }
      )

      expect( context.valid? ).to eq( false )
      expect( context.errors ).not_to be_empty

      error = context.errors.first
      expect( error ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
      expect( error.key ).to eq( :book )
      expect( error.keypath ).to eq( 'book' )

      expect {
        context.validate!
      }.to raise_error( AdaptiveConfiguration::RequirementUnmetError, /required/ )

    end

    it 'the context is valid when required groups parameters are set ( even if empty )' do

      context = AdaptiveConfiguration::Context.new(
        converters: converters, 
        definitions: {
          book: {
            type: :group,
            converters: converters, 
            definitions: {}
          } 
        }
      )

      context.book 
      expect( context.valid? ).to eq( true )
      expect { context.validate! }.not_to raise_error

    end

  end

    it 'the context is valid when required parameter in optional groups are not present' do

      context = AdaptiveConfiguration::Context.new(
        converters: converters, 
        definitions: {
          book: {
            type: :group,
            converters: converters, 
            definitions: {
              title: { type: 'codex', required: true }
            }
          } 
        }
      )

      expect( context.valid? ).to eq( true )
      expect { context.validate! }.not_to raise_error

    end

    it 'the context is invalid when required parameter in required groups are not present' do

      context = AdaptiveConfiguration::Context.new(
        converters: converters, 
        definitions: {
          book: {
            type: :group,
            required: true,
            converters: converters, 
            definitions: {
              title: { type: 'codex', required: true }
            }
          } 
        }
      )

      context.book 

      expect( context.valid? ).to eq( false )
      expect( context.errors ).not_to be_empty

      error = context.errors.first
      expect( error ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
      expect( error.key ).to eq( :title )
      expect( error.keypath ).to eq( 'book/title' )

      expect {
        context.validate!
      }.to raise_error( AdaptiveConfiguration::RequirementUnmetError, /required/ )

    end

end
