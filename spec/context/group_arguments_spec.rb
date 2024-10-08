RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'group types with arguments' do

    it 'handles group nil value parameters correctly' do
      definitions = {
        group_a: {
          type: :group,
          definitions: {
            value_a: {
              type: String
            }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.group_a
      expect( context[ :group_a ][ :value_a ] ).to eq( nil )
      context.group_a nil
      expect( context[ :group_a ][ :value_a ] ).to eq( nil )
    end

    it 'handles group value parameters correctly' do
      definitions = {
        group_a: {
          type: :group,
          definitions: {
            value_a: {
              type: String
            }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.group_a( value_a: 'A' )
      expect( context[ :group_a ][ :value_a ] ).to eq( 'A' )
    end

    it 'handles nested group value parameters correctly' do
      definitions = {
        group_a: {
          type: :group,
          definitions: {
            value_a: {
              type: String
            },
            group_b: {
              type: :group,
              definitions: {
                value_b: {
                  type: String
                }
              }
            }
          }
        }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.group_a( value_a: 'A', group_b: { value_b: 'B' } )
      expect( context[ :group_a ][ :value_a ] ).to eq( 'A' )
      expect( context[ :group_a ][ :group_b ][ :value_b ] ).to eq( 'B' )
    end

  end
end
