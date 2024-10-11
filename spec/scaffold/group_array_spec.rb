require 'spec_helper.rb'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'group array' do
    context 'when a group array is defined' do 

      let( :definitions ) {
        {
          message: {
            type: :group, 
            array: true,
            definitions: {
              role: {},
              text: { type: String }
            }
          }
        }
      }
          
      context 'when the group is called once' do
        context 'through a builder' do
          it 'includes an array of objects' do 
            scaffold = build_scaffold( definitions: definitions )

            scaffold.message do 
              role :system
              text 'text'
            end 
            
            result = scaffold.to_h 
            expect( result[ :message ] ).to_not be_nil
            expect( result[ :message ] ).to be_a( Array )
            expect( result[ :message ].count ).to eq( 1 )
            expect( result[ :message ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :message ][ 0 ][ :text ] ).to eq( 'text' )
          end
        end

        context 'through attributes' do 
          it 'includes an array of objects' do 
            attributes = { message: [ { role: :system, text: 'text' } ] }
            scaffold = build_scaffold( attributes, definitions: definitions )

            result = scaffold.to_h
            expect( result[ :message ] ).to_not be_nil
            expect( result[ :message ] ).to be_a( Array )
            expect( result[ :message ].count ).to eq( 1 )
            expect( result[ :message ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :message ][ 0 ][ :text ] ).to eq( 'text' )
          end
        end
      end

      context 'when the group is called multiple times' do
        context 'through a builder' do
          it 'includes an array of mulitple objects' do 
            scaffold = build_scaffold( definitions: definitions )

            scaffold.message do 
              role :system
              text 'text 0'
            end 
            scaffold.message do 
              role :user
              text 'text 1'
            end 
            
            result = scaffold.to_h
            expect( result[ :message ] ).to_not be_nil
            
            scaffold.message do 
              role :assistant
              text 'text 2'
            end 
            
            result = scaffold.to_h
            expect( result[ :message ] ).to be_a( Array )
            expect( result[ :message ].count ).to eq( 3 )
            expect( result[ :message ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :message ][ 0 ][ :text ] ).to eq( 'text 0' )
            expect( result[ :message ][ 2 ][ :role ] ).to eq( :assistant )
            expect( result[ :message ][ 2 ][ :text ] ).to eq( 'text 2' )
          end
        end

        context 'through attributes' do 
          it 'includes an array of multiple objects' do 
            attributes = { 
              message: [ 
                { role: :system, text: 'text 0' }, 
                { role: :user, text: 'text 1' }, 
                { role: :assistant, text: 'text 2' } 
              ] 
            }
            scaffold = build_scaffold( attributes, definitions: definitions )

            result = scaffold.to_h
            expect( result[ :message ] ).to_not be_nil
            expect( result[ :message ] ).to be_a( Array )
            expect( result[ :message ].count ).to eq( 3 )
            expect( result[ :message ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :message ][ 0 ][ :text ] ).to eq( 'text 0' )
            expect( result[ :message ][ 2 ][ :role ] ).to eq( :assistant )
            expect( result[ :message ][ 2 ][ :text ] ).to eq( 'text 2' )
          end
        end
      end
    end
  end

  describe 'group types with array option nested in groups with array option' do
    context 'when configured with a group array inside a group array' do 

      let( :definitions ) {
        {
          message: {
            type: :group, 
            array: true,
            definitions: {
              role: {},
              content: {
                type: :group,
                array: true,
                definitions: {
                  text: { type: String }
                }
              }
            }
          }
        }
      }
          
      context 'when one array group entry is given' do
        context 'with one array group entry inside that group' do 
          context 'when using a builder' do 
            it 'configures the context with the outer and inner entry' do 
              scaffold = build_scaffold( definitions: definitions )
              
              scaffold.message do 
                role :system
                content do 
                  text 'text'
                end
              end 

              result = scaffold.to_h
              message = result[ :message ]
              expect( message ).to_not be_nil
              expect( message ).to be_a( Array )
              expect( message.count ).to eq( 1 )
              expect( message[ 0 ][ :role ] ).to eq( :system )

              content = result[ :message ][ 0 ][ :content ]
              expect( content ).to_not be_nil
              expect( content ).to be_a( Array )
              expect( content.count )
            end
          end

          context 'when using attributes' do 
            it 'configures the context with the outer and inner entry' do 
              attributes = { message: [ { role: :system, content: [ { text: 'text' } ] } ] }
              scaffold = build_scaffold( attributes, definitions: definitions )

              result = scaffold.to_h
              message = result[ :message ]
              expect( message ).to_not be_nil
              expect( message ).to be_a( Array )
              expect( message.count ).to eq( 1 )
              expect( message[ 0 ][ :role ] ).to eq( :system )

              content = result[ :message ][ 0 ][ :content ]
              expect( content ).to_not be_nil
              expect( content ).to be_a( Array )
              expect( content.count )
            end
          end 
        end
      end
  
    end
  end

  describe 'group types with array option and as option' do
    context 'when configured with a group array' do 

      let( :definitions ) {
        {
          message: {
            type: :group, 
            array: true,
            as: :messages,
            definitions: {
              role: {},
              text: { type: String }
            }
          }
        }
      }
          
      context 'when one array group entry is given' do
        context 'when using a builder' do
          it 'configures the context with the entry' do 
            scaffold = build_scaffold( definitions: definitions )
 
            scaffold.message do 
              role :system
              text 'text'
            end

            result = scaffold.to_h
            expect( result[ :messages ] ).to_not be_nil
            expect( result[ :messages ] ).to be_a( Array )
            expect( result[ :messages ].count ).to eq( 1 )
            expect( result[ :messages ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :messages ][ 0 ][ :text ] ).to eq( 'text' )
          end
        end

        context 'when using a attributes' do 
          it 'configures the context with the entry' do 
            attributes = { message: [ { role: :system, text: 'text' } ] }
            scaffold = build_scaffold( attributes, definitions: definitions )

            result = scaffold.to_h
            expect( result[ :messages ] ).to_not be_nil
            expect( result[ :messages ] ).to be_a( Array )
            expect( result[ :messages ].count ).to eq( 1 )
            expect( result[ :messages ][ 0 ][ :role ] ).to eq( :system )
            expect( result[ :messages ][ 0 ][ :text ] ).to eq( 'text' )
          end
        end
      end

    end
  end

  describe 'group types with array option and as option nested in groups with array option and as option' do
    context 'when configured with a group array inside a group array' do 

      let( :definitions ) {
        {
          message: {
            type: :group, 
            array: true,
            as: :messages,
            definitions: {
              role: {},
              content: {
                type: :group,
                array: true,
                as: :contents,
                definitions: {
                  text: { type: String }
                }
              }
            }
          }
        }
      }
          
      context 'when one array group entry is given' do
        context 'with one array group entry inside that group' do 
          context 'when using a builder' do 
            it 'configures the context with the outer and inner entry' do 
              scaffold = build_scaffold( definitions: definitions )
              
              scaffold.message do 
                role :system
                content do 
                  text 'text'
                end
              end 

              result = scaffold.to_h

              messages = result[ :messages ]
              expect( messages ).to_not be_nil
              expect( messages ).to be_a( Array )
              expect( messages.count ).to eq( 1 )
              expect( messages[ 0 ][ :role ] ).to eq( :system )

              contents = result[ :messages ][ 0 ][ :contents ]
              expect( contents ).to_not be_nil
              expect( contents ).to be_a( Array )
              expect( contents.count )
            end
          end

          context 'when using attributes' do 
            it 'configures the context with the outer and inner entry' do 
              attributes = { message: [ { role: :system, content: [ { text: 'text' } ] } ] }
              scaffold = build_scaffold( attributes, definitions: definitions )

              result = scaffold.to_h
                
              messages = result[ :messages ]
              expect( messages ).to_not be_nil
              expect( messages ).to be_a( Array )
              expect( messages.count ).to eq( 1 )
              expect( messages[ 0 ][ :role ] ).to eq( :system )

              contents = result[ :messages ][ 0 ][ :contents ]
              expect( contents ).to_not be_nil
              expect( contents ).to be_a( Array )
              expect( contents.count )
            end
          end 
        end
      end
  
    end
  end
end
