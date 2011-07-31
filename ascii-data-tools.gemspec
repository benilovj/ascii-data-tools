# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ascii-data-tools/version"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.summary = "A tool for decoding and modifying ASCII CDRs."
  s.name = 'ascii-data-tools'
  s.version = AsciiDataTools::VERSION
  s.authors = ['Jake Benilov']
  s.email = ['benilov@gmail.com']
  s.homepage = 'http://github.com/benilovj/ascii-data-tools'
  s.requirements << 'none'
  s.bindir = 'bin'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.description = s.summary
  s.has_rdoc = false

  s.add_runtime_dependency('terminal-table', '~> 1.4.2')
  
  s.add_development_dependency('rspec')
  s.add_development_dependency('cucumber')
  s.add_development_dependency('ruby-prof')
end
