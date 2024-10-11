require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Scaffold do

  describe 'merge' do

    it 'merges nested contexts correctly' do
      definitions = {
        settings: {
          type: :group,
          definitions: {
            option1: { type: String },
            option2: { type: String }
          }
        }
      }
      scaffold = build_scaffold( definitions: definitions )

      scaffold.settings do
        option1 'value1'
      end

      another_scaffold = build_scaffold( definitions: definitions )
      
      another_scaffold.settings do
        option2 'value2'
      end

      merged_context = scaffold.to_h.merge( another_scaffold.to_h ) do | key, oldval, newval |
        if oldval.is_a?( Hash ) && newval.is_a?( Hash )
          oldval.merge( newval )
        else
          newval
        end
      end

      expect( merged_context ).to eq( { settings: { option1: 'value1', option2: 'value2' } } )
    end

  end

end
