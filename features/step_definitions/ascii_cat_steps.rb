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
  Given "a record stream containing", string
end

When /^ascii_cat is invoked$/ do
  configuration = AsciiDataTools::Configuration.new(@command_line,
    :input_source  => AsciiDataTools::InputSource.new(@record_source_filename, @input_stream),
    :output_stream => @output_stream,
    :record_types  => @record_types
  )

  AsciiDataTools::Controller::CatController.new(configuration).run
end

Then /^the following is printed out:$/ do |string|
  @output_stream.string.should == string
end