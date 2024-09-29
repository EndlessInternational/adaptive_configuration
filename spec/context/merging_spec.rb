RSpec.describe AdaptiveConfiguration::Context do

  let( :converters ) do
    AdaptiveConfiguration::Builder::DEFAULT_CONVERTERS.dup
  end

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

      context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      context.settings do
        option1 'value1'
      end

      another_context = AdaptiveConfiguration::Context.new(
        converters: converters, definitions: definitions
      )
      another_context.settings do
        option2 'value2'
      end

      merged_context = context.to_h.merge( another_context.to_h ) do | key, oldval, newval |
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
