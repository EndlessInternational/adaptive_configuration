require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe ':required option' do

    it 'the context is invalid when required parameters are not set' do

      definitions = {
        api_key: { type: String, required: true }
      }
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.valid? ).to eq( false )
      expect( scaffold.errors ).not_to be_empty

      error = scaffold.errors.first
      expect( error ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
      expect( error.key ).to eq( :api_key )
      expect( error.keypath ).to eq( 'api_key' )

      expect {
        scaffold.validate!
      }.to raise_error( AdaptiveConfiguration::RequirementUnmetError, /required/ )
    
    end

    it 'the context is valid when required parameters are set' do

      definitions = {
        api_key: { type: String, required: true }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.api_key '123'

      expect( scaffold.valid? ).to eq( true )

      expect {
        scaffold.validate!
      }.not_to raise_error

    end

    it 'the context is invalid when required array parameters are not set' do

      definitions = {
        words: { type: String, required: true, array: true  }
      }
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.valid? ).to eq( false )
      expect( scaffold.errors ).not_to be_empty

      error = scaffold.errors.first
      expect( error ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
      expect( error.key ).to eq( :words )
      expect( error.keypath ).to eq( 'words' )

      expect {
        scaffold.validate!
      }.to raise_error( AdaptiveConfiguration::RequirementUnmetError, /required/ )
    
    end

    it 'the context is valid when required array parameters are set' do

      definitions = {
        words: { type: String, required: true, array: true }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.words 'one'
      expect( scaffold.valid? ).to eq( true )

      scaffold.words 'two'
      expect( scaffold.valid? ).to eq( true )

      expect {
        scaffold.validate!
      }.not_to raise_error

    end

    it 'the context is invalid when required groups are not present' do
      definitions = {
        book: {
          type: :group,
          required: true,
          definitions: {}
        } 
      }
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.valid? ).to eq( false )
      expect( scaffold.errors ).not_to be_empty

      error = scaffold.errors.first
      expect( error ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
      expect( error.key ).to eq( :book )
      expect( error.keypath ).to eq( 'book' )

      expect {
        scaffold.validate!
      }.to raise_error( AdaptiveConfiguration::RequirementUnmetError, /required/ )
    end

    it 'the context is valid when required groups parameters are set ( even if empty )' do

      definitions = {
        book: {
          type: :group,
          definitions: {}
        } 
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.book 
      expect( scaffold.valid? ).to eq( true )
      expect { scaffold.validate! }.not_to raise_error

    end

  end

    it 'the context is valid when required parameter in optional groups are not present' do

      definitions = {
        book: {
          type: :group,
          definitions: {
            title: { type: 'codex', required: true }
          }
        } 
      }
      scaffold = build_scaffold( definitions: definitions )

      expect( scaffold.valid? ).to eq( true )
      expect { scaffold.validate! }.not_to raise_error

    end

    it 'the context is invalid when required parameter in required groups are not present' do

      definitions = {
        book: {
          type: :group,
          required: true,
          definitions: {
            title: { type: 'codex', required: true }
          }
        } 
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.book 

      expect( scaffold.valid? ).to eq( false )
      expect( scaffold.errors ).not_to be_empty

      error = scaffold.errors.first
      expect( error ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
      expect( error.key ).to eq( :title )
      expect( error.keypath ).to eq( 'book/title' )

      expect {
        scaffold.validate!
      }.to raise_error( AdaptiveConfiguration::RequirementUnmetError, /required/ )

    end

end
