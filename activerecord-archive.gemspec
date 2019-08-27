
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record/archiver/version"

Gem::Specification.new do |spec|
  spec.name          = "activerecord-archiver"
  spec.version       = ActiveRecord::Archiver::VERSION
  spec.authors       = ["Alessio Signorini"]
  spec.email         = ["asignorini@evidation.com"]

  spec.summary       = 'Simple Archival of ActiveRecord objects'
  spec.homepage      = 'https://github.com/alessiosignorini/activerecord-archiver'
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-s3", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", ">= 1.1"
  spec.add_development_dependency "webmock", "~> 3.5.1"
  spec.add_development_dependency "byebug", "~> 10.0.2"
  spec.add_development_dependency "mocha", "~> 1.8.0"
  spec.add_development_dependency 'pry', '~> 0.12.2'

end
