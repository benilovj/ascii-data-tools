require 'stringio'

Before do |scenario|
  @output_stream = StringIO.new
  @input_stream = StringIO.new
  
  @command_line = []
  
  AsciiDataTools.record_types.clear
  load 'ascii-data-tools/discover.rb'
  @record_types = AsciiDataTools.record_types
end

Given /^a record stream containing$/ do |string|
  @input_stream.string = string
end

Given /^file "([^\"]*)" containing$/ do |filename, string|
  @record_source_filename = filename
  @input_stream.string = string
end

When /^ascii-data-cat is invoked$/ do
  AsciiDataTools::Controller::CatController.new(
    :input_sources => [AsciiDataTools::InputSource.new(@record_source_filename, @input_stream)],
    :output_stream => @output_stream,
    :record_types  => @record_types
  ).run
end

When /^([^\"]*) is invoked on a file "([^\"]*)" containing$/ do |executable, filename, string|
  Given "file \"#{filename}\" containing", string
  When "#{executable} is invoked"
end

When /^([^\"]*) is invoked on a record stream containing$/ do |executable, string|
  Given "a record stream containing", string
  When "#{executable} is invoked"
end

Then /^the following is printed out:$/ do |string|
  @output_stream.string.should == string
end