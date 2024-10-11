require 'spec_helper.rb'

RSpec.describe AdaptiveConfiguration::Scaffold do

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
      scaffold = build_scaffold( definitions: definitions )
     
      scaffold.group_a
      expect( scaffold.to_h[ :group_a ][ :value_a ] ).to eq( nil )
      scaffold.group_a nil
      expect( scaffold.to_h[ :group_a ][ :value_a ] ).to eq( nil )
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
      scaffold = build_scaffold( definitions: definitions )

      scaffold.group_a( value_a: 'A' )
      expect( scaffold.to_h[ :group_a ][ :value_a ] ).to eq( 'A' )
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
      scaffold = build_scaffold( definitions: definitions )
      
      scaffold.group_a( value_a: 'A', group_b: { value_b: 'B' } )
      expect( scaffold.to_h[ :group_a ][ :value_a ] ).to eq( 'A' )
      expect( scaffold.to_h[ :group_a ][ :group_b ][ :value_b ] ).to eq( 'B' )
    end

  end
end
