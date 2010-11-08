require 'rake'

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.summary = "A tool for decoding and modifying ASCII CDRs."
  s.name = 'ascii-data-tools'
  s.version = "0.3"
  s.author = 'Jake Benilov'
  s.email = 'benilov@gmail.com'
  s.homepage = 'http://github.com/benilovj/ascii-data-tools'
  s.requirements << 'none'
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables = ['ascii-data-cat', 'ascii-data-norm', 'ascii-data-tools-config', 'ascii-data-qdiff', 'ascii-data-edit']
  s.files = FileList["{lib,spec,features}/**/*"].to_a + ['Rakefile']
  s.description = s.summary
  s.has_rdoc = false

  s.add_runtime_dependency('terminal-table', '~> 1.4.2')
  
  s.add_development_dependency('rspec', '~> 1.3.1')
  s.add_development_dependency('cucumber')
  s.add_development_dependency('ruby-prof')
end
