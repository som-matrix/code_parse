require_relative "lib/code_parse/version"

Gem::Specification.new do |spec|
  spec.name        = "code_parse"
  spec.version     = CodeParse::VERSION
  spec.authors     = [ "Satya" ]
  spec.email       = [ "swaroopsatya36@gmail.com" ]
  spec.homepage    = "https://example.com"
  spec.summary     = "Parsing engine for your rails app"
  spec.description = "Parsing engine for your rails app"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com"
  spec.metadata["changelog_uri"] = "https://example.com"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.5.2"
  spec.add_dependency "parser"
end
