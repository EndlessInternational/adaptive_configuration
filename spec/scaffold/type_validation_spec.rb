require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'type validation' do

    it 'validates types when setting values' do
      definitions = {
        age: { type: Integer }
      }
      scaffold = build_scaffold( definitions: definitions )

      expect {
        scaffold.age 'not-an-integer'
        scaffold.validate!
      }.to raise_error( 
        AdaptiveConfiguration::IncompatibleTypeError, 
        /expects Integer but received incompatible String/ 
      )

      expect {
        scaffold.age 25
        scaffold.validate!
      }.not_to raise_error

      expect( scaffold[ :age ] ).to eq( 25 )
    end

    it 'validates types in array parameters' do
      definitions = {
        scores: { type: Integer, array: true }
      }
      scaffold = build_scaffold( definitions: definitions )

      expect {
        scaffold.scores [ 100, 95, 85 ]
        scaffold.validate!
      }.not_to raise_error

      expect {
        scaffold.scores [ 100, 'ninety', 85 ]
        scaffold.validate!
      }.to raise_error( 
        AdaptiveConfiguration::IncompatibleTypeError, 
        /expects Integer but received incompatible String/  
      )
    end

  end

end
