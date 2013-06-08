# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'html_trawl/version'

Gem::Specification.new do |spec|
  spec.name          = "html_trawl"
  spec.version       = HtmlTrawl::VERSION
  spec.authors       = ["Dan Nguyen"]
  spec.email         = ["dansonguyen@gmail.com"]
  spec.description   = "A collection of libraries to process web pages"
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_development_dependency 'hashie'
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', "~>2.8"



  spec.add_dependency "mechanize"
  spec.add_dependency "nokogiri"
  spec.add_dependency "pismo"
  spec.add_dependency "ruby-readability"


end
