require 'stringio'

Before do |scenario|
  @output_stream = StringIO.new
  @input_stream = StringIO.new
  
  @command_line = []
  
  @record_types = AsciiEdit::RecordType::RecordTypeRepository.new
end

Given /^a record stream containing$/ do |string|
  @input_stream.string = string
end

Given /^file "([^\"]*)" containing$/ do |filename, string|
  @record_source_filename = filename
  Given "a record stream containing", string
end

When /^ascii_cat is invoked$/ do
  configuration = AsciiEdit::Configuration.new(@command_line,
    :input_source  => AsciiEdit::InputSource.new(@record_source_filename, @input_stream),
    :output_stream => @output_stream,
    :record_types  => @record_types
  )
  
  AsciiEdit::Controller::CatController.new(configuration).run
end

Then /^the following is printed out:$/ do |string|
  @output_stream.string.should == string
end

Given /^fixed\-length record type "([^\"]*)":$/ do |record_type_name, record_type_definition_table|
  extend AsciiEdit::RecordType
  
  fields = []
  record_type_definition_table.hashes.each do |hash|
    field = AsciiEdit::RecordType::FixedLengthField.new(hash["field name"], hash["field length"].to_i)
    constraint_text = hash["constraint"]
    unless constraint_text.nil? or constraint_text.empty?
      if constraint_text =~ /= (.*)/
        value = constraint_text.split("= ")[1]
        field.constraint = equal_to(value)
      elsif constraint_text =~ /one of/
        list_of_possible_values = constraint_text.split("one of ")[1].split(", ")
        field.constraint = one_of(list_of_possible_values)
      end
    end
    fields << field
  end
  @record_types << record_type = AsciiEdit::RecordType::TypeWithFilenameRestrictions.new(record_type_name, fields)
end

Given /^fixed\-length record type "([^\"]*)" which applies for filenames matching "([^\"]*)":$/ do |record_type_name, context_filename_string, record_type_definition_table|
  Given "fixed-length record type \"#{record_type_name}\":", record_type_definition_table
  @record_types.find_by_name(record_type_name).filename_should_match Regexp.new(context_filename_string)
end