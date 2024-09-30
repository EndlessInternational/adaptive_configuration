require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

  describe 'Type Validation' do

    it 'validates types when setting values' do
      definitions = {
        age: { type: Integer }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.age 'not-an-integer'
        context.validate!
      }.to raise_error( 
        AdaptiveConfiguration::IncompatibleTypeError, 
        /expects Integer but received incompatible String/ 
      )

      expect {
        context.age 25
        context.validate!
      }.not_to raise_error

      expect( context[ :age ] ).to eq( 25 )
    end

    it 'validates types in array parameters' do
      definitions = {
        scores: { type: Integer, array: true }
      }

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )

      expect {
        context.scores [ 100, 95, 85 ]
        context.validate!
      }.not_to raise_error

      expect {
        context.scores [ 100, 'ninety', 85 ]
        context.validate!
      }.to raise_error( 
        AdaptiveConfiguration::IncompatibleTypeError, 
        /expects Integer but received incompatible String/  
      )
    end

  end

end
