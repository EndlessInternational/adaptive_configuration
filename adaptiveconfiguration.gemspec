Gem::Specification.new do | spec |

  spec.name          = 'adaptiveconfiguration'
  spec.version       = '1.0.0.beta04'
  spec.authors       = [ 'Kristoph Cichocki-Romanov' ]
  spec.email         = [ 'rubygems.org@kristoph.net' ]

  spec.summary       = <<~TEXT.gsub( "\n", " " ).strip
    An elegant, lightweight and simple yet powerful gem for building structured configuration 
    definitions.
  TEXT
  spec.description   = <<~TEXT.gsub( "\n", " " ).strip
    AdaptiveConfiguration is an elegant, lightweight and simple, yet powerful Ruby gem that allows 
    you to define a DSL (Domain-Specific Language) for structured and hierarchical configurations. 
    It is ideal for defining complex configurations for various use cases, such as API clients, 
    application settings, or any scenario where structured configuration is needed. 

    In addition AdaptiveConfiguration can be more generally used to transform and validate JSON 
    data from any source such as from a network request or API reponse.
  TEXT

  spec.license       = 'MIT'
  spec.homepage      = 'https://github.com/EndlessInternational/adaptive_configuration'
  spec.metadata = {
    'source_code_uri'   => 'https://github.com/EndlessInternational/adaptive_configuration',
    'bug_tracker_uri'   => 'https://github.com/EndlessInternational/adaptive_configuration/issues',
#    'documentation_uri' => 'https://github.com/EndlessInternational/adaptive_configuration'
  }

  spec.required_ruby_version = '>= 3.0'
  spec.files         = Dir[ "lib/**/*.rb", "LICENSE", "README.md", "adaptiveconfiguration.gemspec" ]
  spec.require_paths = [ "lib" ]

  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'debug', '~> 1.9'

end
