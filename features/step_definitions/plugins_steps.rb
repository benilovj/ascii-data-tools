When /^the record type configuration is printed$/ do
  @configuration_printout = AsciiEdit::RecordTypesConfigurationPrinter.for_record_types(@record_types).summary
end

Then /^it should look like this:$/ do |expected_string|
  @configuration_printout.should == expected_string
end
