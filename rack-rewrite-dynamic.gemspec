# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/rewrite/dynamic/version'

Gem::Specification.new do |gem|
  gem.name          = "rack-rewrite-dynamic"
  gem.version       = Rack::Rewrite::Dynamic::VERSION
  gem.authors       = ["Michal Olah"]
  gem.email         = ["olahmichal@gmail.com"]
  gem.description   = %q{Dynamic SEO urls}
  gem.summary       = %q{SEO urls based on slugs}
  gem.homepage      = "https://github.com/bonetics/rack-rewrite-dynamic"

  gem.add_dependency 'rack-rewrite'
  gem.add_dependency 'activesupport'
  gem.add_development_dependency 'rack'
  gem.add_development_dependency "rspec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
