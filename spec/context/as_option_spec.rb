RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe ':as option' do

    it 'uses the :as option to rename keys' do
      definitions = {
        apiKey: { type: String, as: :api_key }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.apiKey 'test-key'

      expect( context[ :api_key ] ).to eq( 'test-key' )
      expect( context[ :apiKey ] ).to be_nil
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

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.settings do
        userName 'testuser'
      end

      expect( context[ :settings ][ :user_name ] ).to eq( 'testuser' )
      expect( context[ :settings ][ :userName ] ).to be_nil
    end

  end

end
