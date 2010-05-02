require 'stringio'

Before do |scenario|
  @output_stream = StringIO.new
  @input_stream = StringIO.new
  
  @command_line = []
  
  @record_types = AsciiDataTools::RecordType::RecordTypeRepository.new
  require 'ascii-data-tools/discover'
  AsciiDataTools.record_types.each {|record_type| @record_types << record_type}
end

Given /^a record stream containing$/ do |string|
  @input_stream.string = string
end

Given /^file "([^\"]*)" containing$/ do |filename, string|
  @record_source_filename = filename
  Given "a record stream containing", string
end

Given /^fixed\-length record type "([^\"]*)":$/ do |record_type_name, record_type_definition_table|
  extend AsciiDataTools::RecordType
  
  fields = []
  record_type_definition_table.hashes.each do |hash|
    field = AsciiDataTools::RecordType::FixedLengthField.new(hash["field name"], hash["field length"].to_i)
    constraint_text = hash["constraint"]
    unless constraint_text.nil? or constraint_text.empty?
      if constraint_text =~ /= (.*)/
        value = constraint_text.split("= ")[1]
        field.should_be_constrained_to(value)
      elsif constraint_text =~ /one of/
        list_of_possible_values = constraint_text.split("one of ")[1].split(", ")
        field.should_be_constrained_to(list_of_possible_values)
      end
    end
    fields << field
  end
  @record_types << record_type = AsciiDataTools::RecordType::TypeWithFilenameRestrictions.new(record_type_name, fields)
end

Given /^fixed\-length record type "([^\"]*)" which applies for filenames matching "([^\"]*)":$/ do |record_type_name, context_filename_string, record_type_definition_table|
  Given "fixed-length record type \"#{record_type_name}\":", record_type_definition_table
  @record_types.find_by_name(record_type_name).filename_should_match Regexp.new(context_filename_string)
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