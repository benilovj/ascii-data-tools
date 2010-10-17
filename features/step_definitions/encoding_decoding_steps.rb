When /^I decode an encoded fixed\-length record "([^\"]*)" of type "([^\"]*)"$/ do |ascii_text, record_type_name|
  ascii_text.gsub!('\\n', "\n")
  @record = @record_types.find_by_name(record_type_name).decode(:ascii_string => ascii_text)
end

Then /^I should have a decoded record of type "([^\"]*)" and contents:$/ do |intended_record_type_name, table|
  @record.type_name.should == intended_record_type_name
  table.hashes.each do |hash|
    expected_value = hash["field value"].gsub('\\n', "\n")
    @record[hash["field name"]].should == expected_value
  end
end
