RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'Handling Defaults in Nested Contexts' do

    it 'applies default values in nested contexts' do
      definitions = {
        outer: {
          type: :group,
          definitions: {
            inner: {
              type: :group,
              definitions: {
                param: { type: String, default: 'default-value' }
              }
            }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect( context[ :outer ][ :inner ][ :param ] ).to eq( 'default-value' )
    end

    it 'overrides default values in nested contexts' do
      definitions = {
        outer: {
          type: :group,
          definitions: {
            inner: {
              type: :group,
              definitions: {
                param: { type: String, default: 'default-value' }
              }
            }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.outer do
        inner do
          param 'new-value'
        end
      end

      expect( context[ :outer ][ :inner ][ :param ] ).to eq( 'new-value' )
    end

  end

end
