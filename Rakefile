require 'bundler/gem_tasks'

require 'cucumber/rake/task'
require 'rspec/core/rake_task'

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
  t.cucumber_opts = "features --format pretty" 
end

RSpec::Core::RakeTask.new

task :default => [:spec, :features]