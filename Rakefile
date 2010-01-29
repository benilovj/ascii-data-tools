require 'cucumber/rake/task'
require 'spec/rake/spectask'
require 'rake/gempackagetask'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty" 
end

desc "Run all examples"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "A tool for decoding and modifying ASCII CDRs."
  s.name = 'ascii-data-tools'
  s.version = "0.3"
  s.requirements << 'none'
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables = ['ascii_cat']
  s.files = FileList["{lib,spec,features}/**/*"].to_a + ['Rakefile']
  s.description = s.summary
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = false
end

task :install_gem => :package do
  `sudo gem install pkg/*.gem`
end

task :default => :install_gem