require 'cucumber/rake/task'
require 'spec/rake/spectask'
require 'rake/gempackagetask'

desc "Profile ascii-data-cat"
task :profile do
  lib_path = File.expand_path("#{File.dirname(__FILE__)}/lib")
  $LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
  
  require 'ascii-data-tools'
  require 'ruby-prof'
  require 'stringio'

  result = RubyProf.profile do
    orig_stdout = $stdout
    
    # redirect stdout to /dev/null
    STDOUT = File.new('/dev/null', 'w')
    
    AsciiDataTools::Controller::CatController.new(['examples/big']).run
    
    # restore stdout
    STDOUT = orig_stdout
  end
  profile = StringIO.new
  RubyProf::FlatPrinter.new(result).print(profile)
  profile.rewind
  puts profile.readlines[0..30]
end

desc "Run all storytests"
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
  s.author = 'Jake Benilov'
  s.email = 'benilov@gmail.com'
  s.homepage = 'http://github.com/benilovj/ascii-data-tools'
  s.requirements << 'none'
  s.require_path = 'lib'
  s.bindir = 'bin'
  s.executables = ['ascii-data-cat', 'ascii-data-norm', 'ascii-data-tools-config', 'ascii-data-qdiff', 'ascii-data-edit']
  s.files = FileList["{lib,spec,features}/**/*"].to_a + ['Rakefile']
  s.description = s.summary
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = false
end

task :install_gem => :package do
  `sudo gem install pkg/*.gem --no-ri --no-rdoc`
end

task :default => :install_gem
