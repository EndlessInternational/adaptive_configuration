require 'spec_helper.rb'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'default options on groups and group members' do

    context 'when a default options is set for a group' do 
      
      let( :definitions ) {
        {
          message: {
            type: :group, 
            default: { role: :default },
            definitions: {
              role: { type: Symbol },
              text: { type: String }
            }
          }
        }
      }

      it 'creates the group and assigns the default value' do
        scaffold = build_scaffold( definitions: definitions )
        scaffold.message { text 'text' }

        expect( scaffold[ :message ][ :role ] ).to eq( :default )
        expect( scaffold[ :message ][ :text ] ).to eq( 'text' )
      end

      context 'and attributes that overide the default are given' do
        it 'replaces the default value' do 
          scaffold = build_scaffold( definitions: definitions )
          scaffold.message( { role: :system, text: 'text' } )
          expect( scaffold[ :message ][ :role ] ).to eq( :system )
          expect( scaffold[ :message ][ :text ] ).to eq( 'text' )
        end
      end

      context 'and a block that overides the default are given' do
        it 'replaces the default value' do 
          scaffold = build_scaffold( definitions: definitions )
          scaffold.message { 
            role  :system
            text  'text' 
          }
          expect( scaffold[ :message ][ :role ] ).to eq( :system )
          expect( scaffold[ :message ][ :text ] ).to eq( 'text' )
        end
      end

      context 'and the parameter is explicitly set' do 
        it 'replaces the defaut value' do 
          scaffold = build_scaffold( definitions: definitions )
          scaffold.message { role :user }
          scaffold.message { text 'text' }

          expect( scaffold[ :message ][ :role ] ).to eq( :user )
          expect( scaffold[ :message ][ :text ] ).to eq( 'text' )
        end
      end

    end

    context 'when a default option is set for a group member' do 
      context 'and the group itself does not have a default' do 

        let( :definitions ) {
          {
            message: {
              type: :group, 
              definitions: {
                role: { type: Symbol, default: :system },
                text: { type: String }
              }
            }
          }
        }
        
        context 'and the group is not explicitly referenced' do 
          it 'does not assign the default' do
            scaffold = build_scaffold( definitions: definitions )
            expect( scaffold[ :message ] ).to be_nil
          end
        end 
        
        context 'and the group is explicitly referenced but the parameter is not' do 
          it 'does assign the default' do 
            scaffold = build_scaffold( definitions: definitions )
            scaffold.message {
              text 'text'
            }
            expect( scaffold[ :message ][ :role ] ).to eq :system
            expect( scaffold[ :message ][ :text ] ).to eq 'text'
          end
        end
      end

      context 'and the group itself does have a default' do 
      
        let( :definitions ) {
          {
            message: {
              type: :group, 
              default: {},
              definitions: {
                role: { type: Symbol, default: :system },
                text: { type: String }
              }
            }
          }
        }
        
        context 'and the group is not explicitly referenced' do 
          it 'it does assign the default' do
            scaffold = build_scaffold( definitions: definitions )
            expect( scaffold[ :message ] ).to_not be_nil
            expect( scaffold[ :message ][ :role ] ).to eq :system
          end
        end 
        
        context 'and the group is explicitly referenced but the parameter with a default is not set' do 
          it 'does assign the default' do 
            scaffold = build_scaffold( definitions: definitions )
            scaffold.message { text 'text' } 
            expect( scaffold[ :message ][ :role ] ).to eq :system
            expect( scaffold[ :message ][ :text ] ).to eq 'text'
          end
        end

      end
    end

  end
end
