require 'spec_helper.rb'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe ':as option' do

    it 'uses the :as option to rename keys' do
      definitions = {
        apiKey: { type: String, as: :api_key }
      }
      scaffold = build_scaffold( definitions: definitions )
      scaffold.apiKey 'test-key'

      result = scaffold.to_h
      expect( result[ :api_key ] ).to eq( 'test-key' )
      expect( result[ :apiKey ] ).to be_nil
    end

    it 'applies the :as option within nested groups' do
      definitions = {
        settings: {
          type: :group,
          definitions: {
            userName: { type: String, as: :user_name }
          }
        }
      }
      scaffold = build_scaffold( definitions: definitions )
      
      scaffold.settings do
        userName 'testuser'
      end
      
      result = scaffold.to_h
      expect( result[ :settings ][ :user_name ] ).to eq( 'testuser' )
      expect( result[ :settings ][ :userName ] ).to be_nil
    end

  end

end
