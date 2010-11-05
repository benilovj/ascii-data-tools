When /^I decode an encoded record "([^\"]*)" of type "([^\"]*)"$/ do |ascii_text, record_type_name|
  ascii_text.gsub!('\\n', "\n")
  @record = @record_types.find_by_name(record_type_name).decode(:ascii_string => ascii_text)
end

When /^I encode a record of type "([^\"]*)" and contents:$/ do |record_type_name, table|
  record_type = @record_types.find_by_name(record_type_name)
  values = table.hashes.collect {|hash| hash["field value"].gsub('\\n', "\n") }
  @record = AsciiDataTools::Record::Record.new(record_type, values)
end

Then /^I should have a decoded record of type "([^\"]*)" and contents:$/ do |intended_record_type_name, table|
  @record.type_name.should == intended_record_type_name
  table.hashes.each do |hash|
    expected_value = hash["field value"].gsub('\\n', "\n")
    @record[hash["field name"]].should == expected_value
  end
end

Then /^I should have a encoded record "([^\"]*)"$/ do |expected_encoded_text|
  expected_encoded_text.gsub!('\\n', "\n")
  @record.encode.should == expected_encoded_text
end