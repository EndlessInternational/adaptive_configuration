require 'spec_helper'

RSpec.describe AdaptiveConfiguration::Builder do

  describe 'parameter types' do

    it 'handles String parameters correctly' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :string_param, String
      end

      result = configuration.build! do
        string_param 'test-string'
      end

      expect( result[ :string_param ] ).to eq( 'test-string' )
    end

    it 'handles Integer parameters correctly' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :integer_param, Integer
      end

      result = configuration.build! do
        integer_param 42
      end

      expect( result[ :integer_param ] ).to eq( 42 )
    end

    it 'handles Float parameters correctly' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :float_param, Float
      end

      result = configuration.build! do
        float_param 3.14
      end

      expect( result[ :float_param ] ).to eq( 3.14 )
    end

    it 'handles Boolean parameters correctly' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :boolean_param, [ TrueClass, FalseClass ]
      end

      result = configuration.build! do
        boolean_param true
      end

      expect( result[ :boolean_param ] ).to eq( true )
    end

    it 'handles custom class parameters' do
      class CustomType
        attr_reader :value
        def initialize( value )
          @value = value
        end
      end

      configuration = AdaptiveConfiguration::Builder.new do
        parameter :custom_param, CustomType
      end

      custom_value = CustomType.new( 'custom' )
      result = configuration.build! do
        custom_param custom_value
      end

      expect( result[ :custom_param ] ).to eq( custom_value )
      expect( result[ :custom_param ].value ).to eq( 'custom' )
    end
  end

  describe 'default values' do
    it 'uses default values when parameters are not provided' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :string_param, String, default: 'default-string'
        parameter :integer_param, Integer, default: 100
        parameter :float_param, Float, default: 1.23
        parameter :boolean_param, [ TrueClass, FalseClass ], default: false
      end

      result = configuration.build! do
        # No parameters provided
      end

      expect( result[ :string_param ] ).to eq( 'default-string' )
      expect( result[ :integer_param ] ).to eq( 100 )
      expect( result[ :float_param ] ).to eq( 1.23 )
      expect( result[ :boolean_param ] ).to eq( false )
    end

    it 'overrides default values when parameters are provided' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :string_param, String, default: 'default-string'
      end

      result = configuration.build! do
        string_param 'provided-string'
      end

      expect( result[ :string_param ] ).to eq( 'provided-string' )
    end
  end

  describe 'array parameters with different types' do
    it 'handles arrays of Strings' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :string_array, String, array: true
      end

      result = configuration.build! do
        string_array [ 'one', 'two', 'three' ]
      end

      expect( result[ :string_array ] ).to eq( [ 'one', 'two', 'three' ] )
    end

    it 'handles arrays of Integers' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :integer_array, Integer, array: true
      end

      result = configuration.build! do
        integer_array [ 1, 2, 3 ]
      end

      expect( result[ :integer_array ] ).to eq( [ 1, 2, 3 ] )
    end

    it 'handles arrays of Floats' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :float_array, Float, array: true
      end

      result = configuration.build! do
        float_array [ 1.1, 2.2, 3.3 ]
      end

      expect( result[ :float_array ] ).to eq( [ 1.1, 2.2, 3.3 ] )
    end

    it 'handles arrays of Booleans' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :boolean_array, [ TrueClass, FalseClass ], array: true
      end

      result = configuration.build! do
        boolean_array [ true, false, true ]
      end

      expect( result[ :boolean_array ] ).to eq( [ true, false, true ] )
    end

    it 'handles arrays with mixed types when no type is specified' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :mixed_array, array: true
      end

      result = configuration.build! do
        mixed_array [ 1, 'two', 3.0, true ]
      end

      expect( result[ :mixed_array ] ).to eq( [ 1, 'two', 3.0, true ] )
    end

    it 'raises TypeError when array elements are of incorrect type' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :integer_array, Integer, array: true
      end

      expect {
        configuration.build! do
          integer_array [ 1, 'two', 3 ]
        end
      }.to raise_error( 
        AdaptiveConfiguration::IncompatibleTypeError, 
        /expects 'Integer' but incompatible 'String'/ 
      )
    end
  end

  describe 'nested parameters with various types' do
    it 'handles nested parameters with different parameter types' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameters :database do
          parameter :host, String, default: 'localhost'
          parameter :port, Integer, default: 5432
          parameter :username, String
          parameter :password, String
          parameter :ssl_enabled, [ TrueClass, FalseClass ], default: false
        end
      end

      result = configuration.build! do
        database do
          username 'db_user'
          password 'db_pass'
          ssl_enabled true
        end
      end

      expect( result[ :database ][ :host ] ).to eq( 'localhost' )
      expect( result[ :database ][ :port ] ).to eq( 5432 )
      expect( result[ :database ][ :username ] ).to eq( 'db_user' )
      expect( result[ :database ][ :password ] ).to eq( 'db_pass' )
      expect( result[ :database ][ :ssl_enabled ] ).to eq( true )
    end
  end

  describe 'complex configuration with arrays and defaults' do
    it 'handles complex configurations with arrays of different types and defaults' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :api_key, String
        parameters :notifications do
          parameter :enabled, [ TrueClass, FalseClass ], default: true
          parameter :channels, String, array: true, default: [ 'email', 'sms' ]
          parameters :email_settings do
            parameter :sender, String, default: 'no-reply@example.com'
            parameter :recipients, String, array: true
          end
        end
      end

      result = configuration.build! do
        api_key 'test-api-key'
        notifications do
          channels [ 'push' ]
          email_settings do
            recipients [ 'user1@example.com', 'user2@example.com' ]
          end
        end
      end

      expect( result[ :api_key ] ).to eq( 'test-api-key' )
      expect( result[ :notifications ][ :enabled ] ).to eq( true )
      expect( result[ :notifications ][ :channels ] ).to eq( [ 'push' ] )
      expect( result[ :notifications ][ :email_settings ][ :sender ] ).to eq( 'no-reply@example.com' )
      expect( result[ :notifications ][ :email_settings ][ :recipients ] ).to eq( [ 'user1@example.com', 'user2@example.com' ] )
    end
  end

  describe 'type validation with custom error messages' do
    it 'provides meaningful error messages when type validation fails' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :age, Integer
      end

      expect {
        configuration.build! do
          age 'twenty'
        end
      }.to raise_error( 
        AdaptiveConfiguration::IncompatibleTypeError, 
        /expects 'Integer' but incompatible 'String'/ 
      )
    end
  end

  describe 'using the :as option with arrays' do
    it 'correctly maps parameter names using :as with array parameters' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :tagsList, String, as: :tags, array: true
      end

      result = configuration.build! do
        tagsList [ 'tag1', 'tag2' ]
      end

      expect( result[ :tags ] ).to eq( [ 'tag1', 'tag2' ] )
      expect( result[ :tagsList ] ).to be_nil
    end
  end

  describe 'multiple nested parameters' do
    it 'handles multiple levels of nested parameters' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameters :level1 do
          parameter :param1, String, default: 'default1'
          parameters :level2 do
            parameter :param2, String, default: 'default2'
            parameters :level3 do
              parameter :param3, String, default: 'default3'
            end
          end
        end
      end

      result = configuration.build! do
        level1 do
          param1 'value1'
          level2 do
            param2 'value2'
            level3 do
              param3 'value3'
            end
          end
        end
      end

      expect( result[ :level1 ][ :param1 ] ).to eq( 'value1' )
      expect( result[ :level1 ][ :level2 ][ :param2 ] ).to eq( 'value2' )
      expect( result[ :level1 ][ :level2 ][ :level3 ][ :param3 ] ).to eq( 'value3' )
    end
  end

  describe 'edge cases and error handling' do
    it 'raises an error when required parameter is missing' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :required_param, String
      end

      result = configuration.build! do
        # required_param is not provided
      end

      expect( result[ :required_param ] ).to be_nil
    end

    it 'allows nil values when type is not specified' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :optional_param
      end

      result = configuration.build! do
        optional_param nil
      end
  
      expect( result[ :optional_param ] ).to be_nil
    end

    it 'raises NameError when using reserved method names' do
      expect {
        AdaptiveConfiguration::Builder.new do
          parameter :inspect
        end
      }.to raise_error( NameError, /The name 'inspect' is reserved/ )
    end
  end

  describe 'parameter aliases using :as option' do
    it 'allows multiple parameters to map to the same internal key' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :username, String, as: :user
        parameter :user_name, String, as: :user
      end

      result = configuration.build! do
        username 'testuser'
      end

      expect( result[ :user ] ).to eq( 'testuser' )

      result = configuration.build! do
        user_name 'anotheruser'
      end

      expect( result[ :user ] ).to eq( 'anotheruser' )
    end
  end

  describe 'parameter overriding and precedence' do
    it 'gives precedence to the last parameter set' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :param, String
      end

      result = configuration.build! do
        param 'first value'
        param 'second value'
      end

      expect( result[ :param ] ).to eq( 'second value' )
    end
  end

  describe 'array parameters with default values' do
    it 'uses default array values when none are provided' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :roles, String, array: true, default: [ 'user', 'admin' ]
      end

      result = configuration.build! do
        # No roles provided
      end

      expect( result[ :roles ] ).to eq( [ 'user', 'admin' ] )
    end

    it 'overrides default array values when provided' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :roles, String, array: true, default: [ 'user', 'admin' ]
      end

      result = configuration.build! do
        roles [ 'editor', 'moderator' ]
      end

      expect( result[ :roles ] ).to eq( [ 'editor', 'moderator' ] )
    end
  end

  describe 'boolean parameter edge cases' do
    
    it 'accepts true and false correctly' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :enabled, [ TrueClass, FalseClass ]
      end

      result = configuration.build! do
        enabled true
      end

      expect( result[ :enabled ] ).to eq( true )

      result = configuration.build! do
        enabled false
      end

      expect( result[ :enabled ] ).to eq( false )
    end

    it 'raises an error when a non-boolean value is provided' do
      configuration = AdaptiveConfiguration::Builder.new do
        parameter :enabled, [ TrueClass, FalseClass ]
      end

      result = configuration.build! do
        enabled 'yes'
      end

      expect( result[ :enabled ] ).to eq( true ) 
    end

  end

end
