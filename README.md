# AdaptiveConfiguration

**AdaptiveConfiguration** is a Ruby gem that provides a powerful and flexible DSL for defining structured and hierarchical configurations. It allows you to create dynamic, type-checked parameters and nested groups, making it ideal for defining complex configurations for various use cases, such as API clients or application settings.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adaptive_configuration'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install adaptive_configuration
```

## Usage

### Requiring the Gem

To start using the `adaptive_configuration` gem, simply require it in your Ruby application:

```ruby
require 'adaptive_configuration'
```

### Basic Example

Here is a simple example to get started with defining parameters and building a configuration object:

```ruby
require 'adaptive_configuration'

# Define a configuration structure
configuration = AdaptiveConfiguration::Builder.new do 
  parameter :api_key, String
  parameter :version, String, default: '1.0'
end

# Build the configuration and set values
result = configuration.build do 
  api_key 'your-api-key'
end

# Access the configuration values
puts result[:api_key]    # => "your-api-key"
puts result[:version]    # => "1.0"
```

### Nested Groups Example

You can define nested groups to structure related configurations together:

```ruby
require 'adaptive_configuration'

configuration = AdaptiveConfiguration::Builder.new do 
  parameter :api_key, String
  group :chat_options do
    parameter :model, String, default: 'claude-3'
    parameter :max_tokens, Integer, default: 1000
    parameter :temperature, Float, default: 0.5
    parameter :stream, Boolean
  end
end

result = configuration.build do 
  api_key 'your-api-key'
  chat_options do
    temperature 0.8
    stream true
  end
end

puts result[:chat_options][:model]        # => "claude-3"
puts result[:chat_options][:temperature]  # => 0.8
puts result[:chat_options][:stream]       # => true
```

### Array Parameters Example

You can use array parameters to store multiple values for a single configuration key:

```ruby
require 'adaptive_configuration'

configuration = AdaptiveConfiguration::Builder.new do 
  parameter :api_key, String
  group :request_options do
    parameter :headers, String, array: true
  end
end

result = configuration.build do 
  api_key 'your-api-key'
  request_options do
    headers ['Content-Type: application/json', 'Authorization: Bearer token']
  end
end

puts result[:request_options][:headers] # => ["Content-Type: application/json", "Authorization: Bearer token"]
```

### Complex Example with Nested Groups and Arrays

Here's a more complex example that combines all the features:

```ruby
require 'adaptive_configuration'

configuration = AdaptiveConfiguration::Builder.new do 
  parameter :api_key, String
  group :chat_options do
    parameter :model, String, default: 'claude-3-5'
    parameter :max_tokens, Integer, default: 2000
    parameter :temperature, Float, default: 0.7
    parameter :stream, Boolean
    parameter :stop_sequences, String, array: true

    group :metadata do
      parameter :user_id, String
      parameter :session_id, String
    end
  end

  group :message, as: :messages, array: true do 
    parameter :role, String
    parameter :content, String
  end
end

result = configuration.build do 
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
puts result[:api_key] # => "your-api-key"
puts result[:chat_options][:metadata][:user_id] # => "user-123"
puts result[:messages].map { |msg| msg[:content] }
# => ["You are a helpful assistant.", "Hello!"]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/EndlessInternational/adaptive-configuration](https://github.com/EndlessInternational/adaptive-configuration).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
