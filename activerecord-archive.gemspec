
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record/archiver/version"

Gem::Specification.new do |spec|
  spec.name          = "evidation-activerecord-archiver"
  spec.version       = ActiveRecord::Archiver::VERSION
  spec.authors       = ["Alessio Signorini"]
  spec.email         = ["asignorini@evidation.com"]

  spec.summary       = 'Simple Archival of ActiveRecord Objects'
  spec.homepage      = 'https://github.com/alessiosignorini/activerecord-archiver'
  spec.license       = "MIT"

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.files         = Dir['lib/**/*.rb']

  spec.add_dependency "aws-sdk-s3", "~> 1.0"
  spec.add_dependency "activesupport", "~> 5.2"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "webmock", '~> 3.5', '>= 3.5.1'
  spec.add_development_dependency "byebug", '~> 10.0', '>= 10.0.2'
  spec.add_development_dependency "mocha", '~> 1.8', '>= 1.8.0'
  spec.add_development_dependency 'pry', '~> 0.12.2'

end
