require 'spec_helper.rb'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'default options on parameters and parameters members' do

    context 'when a default options is set for parameters' do 
      
      let( :definitions ) {
        {
          message: {
            type: Object, 
            default: { role: :default },
            definitions: {
              role: { type: Symbol },
              text: { type: String }
            }
          }
        }
      }

      it 'creates the parameters and assigns the default value' do
        scaffold = build_scaffold( definitions: definitions )
        scaffold.message { text 'text' }
        
        result = scaffold.to_h
        expect( result[ :message ][ :role ] ).to eq( :default )
        expect( result[ :message ][ :text ] ).to eq( 'text' )
      end

      context 'and attributes that overide the default are given' do
        it 'replaces the default value' do 
          scaffold = build_scaffold( definitions: definitions )
          scaffold.message( { role: :system, text: 'text' } )

          result = scaffold.to_h
          expect( result[ :message ][ :role ] ).to eq( :system )
          expect( result[ :message ][ :text ] ).to eq( 'text' )
        end
      end

      context 'and a block that overides the default are given' do
        it 'replaces the default value' do 
          scaffold = build_scaffold( definitions: definitions )
          scaffold.message { 
            role  :system
            text  'text' 
          }

          result = scaffold.to_h
          expect( result[ :message ][ :role ] ).to eq( :system )
          expect( result[ :message ][ :text ] ).to eq( 'text' )
        end
      end

      context 'and the parameter is explicitly set' do 
        it 'replaces the defaut value' do 
          scaffold = build_scaffold( definitions: definitions )
          scaffold.message { role :user }
          scaffold.message { text 'text' }

          result = scaffold.to_h
          expect( result[ :message ][ :role ] ).to eq( :user )
          expect( result[ :message ][ :text ] ).to eq( 'text' )
        end
      end

    end

    context 'when a default option is set for parameters member' do 
      context 'and the parameters do not have a default' do 

        let( :definitions ) {
          {
            message: {
              type: Object, 
              definitions: {
                role: { type: Symbol, default: :system },
                text: { type: String }
              }
            }
          }
        }
        
        context 'and the parameters are not explicitly referenced' do 
          it 'does not assign the default' do
            scaffold = build_scaffold( definitions: definitions )

            result = scaffold.to_h
            expect( result[ :message ] ).to be_nil
          end
        end 
        
        context 'and the parameters are explicitly referenced but the parameter is not' do 
          it 'does assign the default' do 
            scaffold = build_scaffold( definitions: definitions )
            scaffold.message {
              text 'text'
            }

            result = scaffold.to_h
            expect( result[ :message ][ :role ] ).to eq :system
            expect( result[ :message ][ :text ] ).to eq 'text'
          end
        end
      end

      context 'and the parameters do not have a default' do 
      
        let( :definitions ) {
          {
            message: {
              type: Object, 
              default: {},
              definitions: {
                role: { type: Symbol, default: :system },
                text: { type: String }
              }
            }
          }
        }
        
        context 'and the parameters are not explicitly referenced' do 
          it 'it does assign the default' do
            scaffold = build_scaffold( definitions: definitions )

            result = scaffold.to_h
            expect( result[ :message ] ).to_not be_nil
            expect( result[ :message ][ :role ] ).to eq :system
          end
        end 
        
        context 'and the parameters are explicitly referenced but the parameter with a default is not set' do 
          it 'does assign the default' do 
            scaffold = build_scaffold( definitions: definitions )
            scaffold.message { text 'text' } 

            result = scaffold.to_h
            expect( result[ :message ][ :role ] ).to eq :system
            expect( result[ :message ][ :text ] ).to eq 'text'
          end
        end

      end
    end

  end
end
