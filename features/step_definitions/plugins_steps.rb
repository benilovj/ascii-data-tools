When /^the record type configuration is printed$/ do
  @configuration_printout = AsciiDataTools::RecordTypesConfigurationPrinter.for_record_types(@record_types).summary
end

Then /^it should look like this:$/ do |expected_string|
  @configuration_printout.should == expected_string
end

Given /^the following is specified in discover\.rb:$/ do |code|
  instance_eval(code)
  @record_types = AsciiDataTools.record_types
end
