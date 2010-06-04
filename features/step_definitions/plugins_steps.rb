Given /^the following configuration:$/ do |code|
  @record_types.instance_eval(code)
end

When /^the record type configuration is printed$/ do
  @configuration_printout = AsciiDataTools::RecordTypesConfigurationPrinter.for_record_types(@record_types).summary
end

Then /^it should look like this:$/ do |expected_string|
  @configuration_printout.should == expected_string
end