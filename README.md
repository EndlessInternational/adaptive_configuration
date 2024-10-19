# AdaptiveConfiguration

**AdaptiveConfiguration** is a powerful and flexible Ruby gem that allows you to define a DSL 
(Domain-Specific Language) for structured and hierarchical configurations. It is ideal for defining 
complex configurations for various use cases, such as API clients, application settings, or 
any scenario where structured configuration is needed. 

In addition AdaptiveConfiguration can be more generally used to transform and validate JSON data 
from any source such as network request or API reponse.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adaptiveconfiguration'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install adaptiveconfiguration
```

## Usage

### Requiring the Gem

To start using the `adaptiveconfiguration` gem, simply require it in your Ruby application:

```ruby
require 'adaptiveconfiguration'
```

### Defining Configurations with AdaptiveConfiguration

AdaptiveConfiguration permits the caller to instantiate define a domain specific language 
+Builder+ with parameters, parameter collections, and related options. The builder can then
be used to build or validate a configuration using a domain specific buildler. 

The build method always returns a Hash with symbolic keys/

---

## Parameters

**Parameters** are the basic building blocks of your configuration. They represent individual 
settings or options that you can define with specific types, defaults, and other attributes.

When defining a parameter, you specify its name and optionally type, default and other options.

### Example:

```ruby
require 'adaptiveconfiguration'

# define a configuration structure with parameters
configuration = AdaptiveConfiguration::Builder.new do
  parameter :api_key
  parameter :version, String, default: '1.0'
end

# build the configuration and set values
result = configuration.build! do
  api_key 'your-api-key'
end

# access the configuration values
puts result[:api_key]   # => "your-api-key"
puts result[:version]   # => "1.0"
```

**Notes:**

- **Defining Parameters:**
  - `parameter :api_key` defines a parameter named `:api_key`. A value of any type can be used to 
    assign the parameter.
  - `parameter :version, String, default: '1.0'` defines a parameter with a default value.
- **Building the Configuration:**
  - `configuration.build!` creates a context where you can set values for the parameters.
  - Inside the block, `api_key 'your-api-key'` sets the value of `:api_key`.
- **Accessing Values:**
  - `result[:api_key]` retrieves the value of `:api_key`.
  - If a parameter has a default and you don't set it, it uses the default value.

---

## Hierarchical Parameters

**Parameters** may be organized hierarchically, grouping related parameters. 

### Example:

```ruby
require 'adaptiveconfiguration'

configuration = AdaptiveConfiguration::Builder.new do
  parameter :api_key, String
  parameters :chat_options do
    parameter :model, String, default: 'claude-3'
    parameter :max_tokens, Integer, default: 1000
    parameter :temperature, Float, default: 0.5
    parameter :stream, TrueClass
  end
end

result = configuration.build! do
  api_key 'your-api-key'
  chat_options do
    temperature 0.8
    stream true
  end
end

# Accessing values
puts result[:api_key]                     # => "your-api-key"
puts result[:chat_options][:model]        # => "claude-3"
puts result[:chat_options][:temperature]  # => 0.8
puts result[:chat_options][:stream]       # => true
```

**Notes:**

- **Defining a parameters collection:**
  - `parameters :chat_options do ... end` defines parameters named `:chat_options`.
  - Inside the parameters collection, you can define parameters that belong to that collection.
- **Setting Values in parameter colleciton:**
  - In the build block, you can set values for parameters within parameters by nesting blocks.
  - `chat_options do ... end` allows you to set parameters inside the `:chat_options` parameters.
- **Accessing Values:**
  - You access parameters parameters by chaining the keys: `result[:chat_options][:model]`.

---

## Array Parameters

**Array Parameters** allow you to define parameters that can hold multiple values. This is 
useful when you need to collect lists of items, such as headers, tags, or multiple 
configuration entries.

### Example:

```ruby
require 'adaptiveconfiguration'

configuration = AdaptiveConfiguration::Builder.new do
  parameter :api_key, String
  parameters :request_options do
    parameter :headers, String, array: true
  end
end

result = configuration.build! do
  api_key 'your-api-key'
  request_options do
    headers 'Content-Type: application/json'
    headers 'Authorization: Bearer token'
  end
end

# ... or alterativelly 

result = configuration.build! do
  api_key 'your-api-key'
  request_options do
    headers ['Content-Type: application/json', 'Authorization: Bearer token']
  end
end

# Accessing array parameter
puts result[:request_options][:headers]
# => ["Content-Type: application/json", "Authorization: Bearer token"]
```

**Notes:**

- **Defining an Array Parameter:**
  - `parameter :headers, String, array: true` defines `:headers` as an array parameter of 
    type `String`.
- **Setting Values:**
  - You can assign multiple headers to the array by calling the `headers` method muliple 
    times ( or optionally, simply passing the method an array ).
- **Accessing Values:**
  - The values are stored as an array, and you can access them directly.

---

## The `:as` Option

The `:as` option allows you to map the parameter's name in your DSL to a different key in the 
resulting configuration. This is useful when you need to conform to specific key names required 
by APIs or other systems, while still using friendly method names in your configuration blocks.

### Example:

```ruby
require 'adaptiveconfiguration'

configuration = AdaptiveConfiguration::Builder.new do
  parameter :api_key, String, as: :apiKey
  parameters :user_settings, as: :userSettings do
    parameter :user_name, String, as: :userName
  end
end

result = configuration.build! do
  api_key 'your-api-key'
  user_settings do
    user_name 'john_doe'
  end
end

# Accessing values with mapped keys
puts result[:apiKey]                    # => "your-api-key"
puts result[:userSettings][:userName]  # => "john_doe"
```

**Notes:**

- **Using the `:as` Option:**
  - `parameter :apiKey, String, as: :api_key` defines a parameter that you set using `apiKey`, 
     but it's stored as `:api_key` in the result.
  - Similarly, `parameters :userSettings, as: :user_settings` maps the parameters name.
- **Setting Values:**
  - In the build block, you use the original names (`apiKey`, `userSettings`), but the values 
    are stored under the mapped keys.
- **Accessing Values:**
  - You access the values using the mapped keys (`:api_key`, `:user_settings`, `:user_name`).

---

## Default Values

The `default` option allows you to specify a default value for a parameter. If you do not set 
a value for that parameter during the build phase, it automatically uses the default.

### Example:

```ruby
require 'adaptiveconfiguration'

configuration = AdaptiveConfiguration::Builder.new do
  parameter :api_key, String, default: 'default-api-key'
  parameters :settings do
    parameter :timeout, Integer, default: 30
    parameter :retries, Integer, default: 3
  end
end

result = configuration.build! do
  # No need to set api_key or settings parameters unless you want to override defaults
end

# Accessing default values
puts result[:api_key]              # => "default-api-key"
puts result[:settings][:timeout]   # => 30
puts result[:settings][:retries]   # => 3
```

**Notes:**

- **Defining Defaults:**
  - Parameters like `:api_key` have a default value specified with `default: 'default-api-key'`.
- **Building Without Setting Values:**
  - If you do not provide values during the build phase, the defaults are used.
- **Accessing Values:**
  - The result contains the default values for parameters you didn't set.

---

## Type Conversion

AdaptiveConfiguration automatically handles type conversion based on the parameter's specified 
type. If you provide a value that can be converted to the specified type, it will do so. 
If conversion fails, the value will remain unchanged. 

You can call +valid?+, +validate+ or +valiate!+ on your builder instance to return true if all 
types are valid, return an array of type errors, or raise an exception when a type error is 
encoutered. 

### Example:

```ruby
require 'adaptiveconfiguration'

configuration = AdaptiveConfiguration::Builder.new do
  parameter :max_tokens, Integer
  parameter :temperature, Float
  parameter :start_date, Date
end

result = configuration.build! do
  max_tokens '1500'       # String that can be converted to Integer
  temperature '0.75'      # String that can be converted to Float
  start_date '2023-01-01' # String that can be converted to Date
end

# Accessing converted values
puts result[:max_tokens]   # => 1500 (Integer)
puts result[:temperature]  # => 0.75 (Float)
puts result[:start_date]   # => #<Date: 2023-01-01 ...>
```

**Notes:**

- **Type Conversion:**
  - AdaptiveConfiguration converts `'1500'` to `1500` (Integer).
  - Converts `'0.75'` to `0.75` (Float).
  - Converts `'2023-01-01'` to a `Date` object.

---

## Custom Converters

You can define custom converters for your own types, allowing you to extend the gem's 
capabilities.

### Example:

```ruby
require 'adaptiveconfiguration'

# define a custom class
class UpcaseString < String
  def initialize( value )
    super( value.to_s.upcase )
  end
end

configuration = AdaptiveConfiguration::Builder.new do
  convert( UpcaseString ) { | v | UpcaseString.new( v ) }
  parameter :name, UpcaseString
end

result = configuration.build! do
  name 'john doe'
end

# Accessing custom converted value
puts result[:name]          # => "JOHN DOE"
puts result[:name].class    # => UpcaseString
```

**Notes:**

- **Defining a Custom Converter:**
  - `convert( UpcaseString ) { | v | UpcaseString.new( v ) }` tells the builder how to convert 
    values to `UpcaseString`.
- **Using Custom Types:**
  - `parameter :name, UpcaseString` defines a parameter of the custom type.
- **Conversion Behavior:**
  - When you set `name 'john doe'`, it converts it to `'JOHN DOE'` and stores it as an instance 
    of `UpcaseString`.

---

## Transforming and Validating JSON Data

AdaptiveConfiguration can also be utilized to transform and validate JSON data. By defining 
parameters and parameter collection that mirror the expected structure of your JSON input, you 
can map and coerce incoming data into the desired format. 

The `:as` option allows you to rename keys during this transformation process, ensuring that your 
data conforms to specific API requirements or internal data models. Moreover, AdaptiveConfiguration 
provides built-in validation by raising exceptions when the input data contains unexpected 
elements or elements of the wrong type, helping you maintain data integrity and catch errors early 
in your data processing pipeline.

### Example:

```ruby
require 'adaptiveconfiguration'

# Define the expected structure of the JSON data
configuration = AdaptiveConfiguration::Builder.new do
  parameter :api_key, String
  parameters :user, as: :user_info do
    parameter :name, String
    parameter :email, String
    parameter :age, Integer
  end
  parameters :preferences, as: :user_preferences do
    parameter :notifications_enabled, TrueClass
    parameter :theme, String, default: 'light'
  end
end

# sample JSON data as a Hash (e.g., parsed from JSON/YAML or API response
input_data = {
  'api_key' => 'your-api-key',
  'user' => {
    'name' => 'John Doe',
    'email' => 'john@example.com',
    'age' => '30'  # age is a String that should be converted to Integer
  },
  'preferences' => {
    'notifications_enabled' => 'true',  # Should be converted to TrueClass
    'theme' => 'dark'
  },
  'extra_field' => 'unexpected'  # This field is not defined in the configuration
}

# build the configuration context using the input data
begin
  
  result = configuration.build!( input_data )

  # Access transformed and validated data
  puts result[:api_key]                      # => "your-api-key"
  puts result[:user_info][:name]             # => "John Doe"
  puts result[:user_info][:age]              # => 30 (Integer)
  puts result[:user_preferences][:theme]     # => "dark"

rescue AdaptiveConfiguration::Error  => e
  puts "Validation Error: #{e.message}"
end
```

**Explanation:**

- **Defining the Structure:**
  - **Parameters and parameters:**
    - We define a configuration that reflects the expected structure of the input JSON data.
    - `parameter :api_key, String` defines the API key parameter.
    - `parameters :user, as: :user_info` defines a parameters for user data, which will be transformed to the key `:user_info` in the result.
    - Inside the `:user` parameters, we define parameters for `:name`, `:email`, and `:age`.
    - `parameters :preferences, as: :user_preferences` defines a parameters for user preferences, transformed to `:user_preferences`.
  - **Using the `:as` Option:**
    - The `:as` option renames the parameters keys in the resulting configuration, allowing the internal DSL names to differ from the output keys.

- **Building the Configuration Context:**
  - **Using `build!`:**
    - We use the `build!` method to enforce strict validation. If any type coercion fails or if unexpected elements are present, it raises an exception.
  - **Setting Values from Input Data:**
    - We set the values by extracting them from the `input_data` hash.
    - For example, `api_key input_data['api_key']` sets the `:api_key` parameter.
    - Within the `user` and `preferences` parameters, we set the nested parameters accordingly.

- **Type Conversion and Coercion:**
  - **Automatic Conversion:**
    - The gem attempts to coerce input values to the specified types.
    - `'30'` (String) is converted to `30` (Integer) for the `:age` parameter.
    - `'true'` (String) is converted to `true` (TrueClass) for `:notifications_enabled`.
  - **Error Handling:**
    - If the input value cannot be coerced to the specified type, a `TypeError` is raised.
    - For instance, if `'thirty'` were provided for `:age`, it would raise a `TypeError` because it cannot be converted to an Integer.

- **Validation:**
  - **Unexpected Elements:**
    - The `build!` method currently does not raise an exception for unexpected keys in the input data (like `'extra_field'`), but these keys are ignored.
    - If you require strict validation against unexpected keys, additional validation logic would need to be implemented.
  - **Type Enforcement:**
    - The gem enforces that the values match the expected types, ensuring data integrity.
    - This helps catch errors early, preventing invalid data from propagating through your application.

- **Transformation:**
  - **Key Renaming:**
    - The use of the `:as` option transforms the internal parameter and parameters names to match the desired output keys.
    - This is particularly useful when the input data keys do not align with the output format required by your application or when interfacing with external APIs.
  - **Structuring Data:**
    - By defining the configuration structure, you effectively map and reorganize the input data into a format that suits your needs.

- **Accessing Transformed Data:**
  - **Resulting Configuration:**
    - The `result` object contains the transformed and validated data.
    - You can access the data using the mapped keys, such as `result[:user_info][:name]`.
  - **Usage in Application:**
    - The validated and transformed data is now ready for use within your application, confident that it adheres to the expected structure and types.

**Note:**

- **Extending Validation:**
  - If you need to validate against unexpected keys (e.g., to ensure there are no extra fields in the input data), you can extend the gem's functionality.
  - This could involve comparing the keys in the input data with the defined parameters and raising an error if discrepancies are found.
- **Flexible Handling:**
  - For scenarios where you prefer not to raise exceptions on type coercion failures, you can use the `build` method instead of `build!`.
  - The `build` method will attempt type coercion but will retain the original value if coercion fails, without raising an exception.


By leveraging AdaptiveConfiguration in this way, you can create robust data transformation and validation pipelines that simplify handling complex JSON data structures, ensuring your application receives data that is correctly typed and structured.

---

## Complex Example with Nested parameters and Arrays

Here's a comprehensive example that combines parameters, parameters, array parameters, and defaults.

### Example:

```ruby
require 'adaptiveconfiguration'

configuration = AdaptiveConfiguration::Builder.new do
  parameter :api_key, String
  parameters :chat_options do
    parameter :model, String, default: 'claude-3-5'
    parameter :max_tokens, Integer, default: 2000
    parameter :temperature, Float, default: 0.7
    parameter :stream, TrueClass
    parameter :stop_sequences, String, array: true

    parameters :metadata do
      parameter :user_id, String
      parameter :session_id, String
    end
  end

  parameters :message, as: :messages, array: true do
    parameter :role, String
    parameter :content, String
  end
end

result = configuration.build! do
  api_key 'your-api-key'

  chat_options do
    temperature 0.5
    stop_sequences ['end', 'stop']
    metadata do
      user_id 'user-123'
      session_id 'session-456'
    end
  end

  message do
    role 'system'
    content 'You are a helpful assistant.'
  end

  message do
    role 'user'
    content 'Hello!'
  end
end

# Accessing values
puts result[:api_key]                            # => "your-api-key"
puts result[:chat_options][:model]               # => "claude-3-5"
puts result[:chat_options][:temperature]         # => 0.5
puts result[:chat_options][:metadata][:user_id]  # => "user-123"
puts result[:messages].map { | msg | msg[:content] }
# => ["You are a helpful assistant.", "Hello!"]
```

**Notes:**

- **Combining Concepts:**
  - Parameters with defaults (`:model`, `:max_tokens`).
  - Nested parameters (`:chat_options`, `:metadata`).
  - Array parameters (`:stop_sequences`, `:messages`).
  - Using the `:as` option to map `:message` to `:messages`.
- **Setting Values:**
  - Override default values by providing new ones.
  - Add multiple messages to the `:messages` array.
- **Accessing Values:**
  - Use nested keys to access deeply nested values.

---

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/EndlessInternational/adaptive-configuration](https://github.com/EndlessInternational/adaptive-configuration).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
