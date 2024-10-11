require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Builder do
  describe '#validate' do

    context 'with a builder defining a single paramter' do
      context 'with a parameter that includes a :type option' do
        it 'validates the parameter' do
          builder = construct_builder do 
            parameter :a_parameter, type: Integer
          end

          expect( builder.validate( { a_parameter: 0 } ) ).to eq( [] )
          expect( builder.valid?( { a_parameter: 0 } ) ).to eq( true )
          
          result = builder.validate( { a_parameter: 'nan' } )
          expect( result ).to be_a( Array )
          expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::IncompatibleTypeError )

          expect( builder.valid?( { a_parameter: 'nan' } ) ).to eq( false )
        end
      end
      context 'with a parameter that includes a :required option' do
        it 'validates the parameter' do
          builder = construct_builder do 
            parameter :a_parameter, required: true 
          end

          expect( builder.validate( { a_parameter: 0 } ) ).to eq( [] )
          expect( builder.valid?( { a_parameter: 0 } ) ).to eq( true )
          expect( builder.validate( { a_parameter: 'nan' } ) ).to eq( [] )
          expect( builder.valid?( { a_parameter: 'nan' } ) ).to eq( true )

          result = builder.validate( {} )
          expect( result ).to be_a( Array )
          expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::RequirementUnmetError )

          expect( builder.valid?( {} ) ).to eq( false )
        end
      end
      context 'with a parameter that includes a :type and a :required option' do
        it 'validates the parameter' do
          builder = construct_builder do 
            parameter :a_parameter, type: Integer, required: true 
          end

          expect( builder.validate( { a_parameter: 0 } ) ).to eq( [] )
          expect( builder.valid?( { a_parameter: 0 } ) ).to eq( true )

          result = builder.validate( { a_parameter: 'nan' } )
          expect( result ).to be_a( Array )
          expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::IncompatibleTypeError )
          expect( builder.valid?( { a_parameter: 'nan' } ) ).to eq( false )

          result = builder.validate( {} )
          expect( result ).to be_a( Array )
          expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
          expect( builder.valid?( {} ) ).to eq( false )
        end
      end
    end

    context 'with a builder defining a single paramter inside a group' do
      context 'with a group that is not required' do 
        context 'with a parameter that includes a :type option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              group :a_group do 
                parameter :a_parameter, type: Integer
              end
            end

            expect( builder.validate( { a_group: { a_parameter: 0 } } ) ).to eq( [] )

            result = builder.validate( { a_group: { a_parameter: 'nan' } } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::IncompatibleTypeError )
          end
        end
        context 'with a parameter that includes a :required option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              group :a_group do 
                parameter :a_parameter, required: true
              end
            end

            expect( builder.validate( { a_group: { a_parameter: 0 } } ) ).to eq( [] )
            expect( builder.validate( { a_group: { a_parameter: 'nan' } } ) ).to eq( [] )

            result = builder.validate( {} )
            expect( result ).to eq( [] )
          end
        end
        context 'with a parameter that includes a :type and a :required option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              group :a_group do 
                parameter :a_parameter, type: Integer, required: true
              end
            end

            expect( builder.validate( { a_group: { a_parameter: 0 } } ) ).to eq( [] )

            result = builder.validate( { a_group: { a_parameter: 'nan' } } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::IncompatibleTypeError )

            result = builder.validate( {} )
            expect( result ).to eq( [] )
          end
        end
      end
      context 'with a group that is required' do 
        context 'with a parameter that includes a :type option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              group :a_group, required: true do 
                parameter :a_parameter, type: Integer
              end
            end

            expect( builder.validate( { a_group: { a_parameter: 0 } } ) ).to eq( [] )

            result = builder.validate( { a_group: { a_parameter: 'nan' } } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::IncompatibleTypeError )
          end
        end
        context 'with a parameter that includes a :required option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              group :a_group, required: true do 
                parameter :a_parameter, required: true
              end
            end

            expect( builder.validate( { a_group: { a_parameter: 0 } } ) ).to eq( [] )
            expect( builder.validate( { a_group: { a_parameter: 'nan' } } ) ).to eq( [] )

            result = builder.validate( {} )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
          end
        end
        context 'with a parameter that includes a :type and a :required option' do
          it 'validates the parameter' do
            builder = construct_builder do 
              group :a_group, required: true do 
                parameter :a_parameter, type: Integer, required: true
              end
            end

            expect( builder.validate( { a_group: { a_parameter: 0 } } ) ).to eq( [] )

            result = builder.validate( { a_group: { a_parameter: 'nan' } } )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::IncompatibleTypeError )

            result = builder.validate( {} )
            expect( result ).to be_a( Array )
            expect( result[ 0 ] ).to be_a( AdaptiveConfiguration::RequirementUnmetError )
          end
        end
      end
     end

  end
end
