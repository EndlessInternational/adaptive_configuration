require 'spec_helper.rb'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'parameters with arguments' do

    it 'handles nil parameters argument correctly' do
      definitions = {
        group_a: {
          type: Object,
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

    it 'handles values inside parameters correctly' do
      definitions = {
        group_a: {
          type: Object,
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

    it 'handles values inside paramters inside parameters correctly' do
      definitions = {
        group_a: {
          type: Object,
          definitions: {
            value_a: {
              type: String
            },
            group_b: {
              type: Object,
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
