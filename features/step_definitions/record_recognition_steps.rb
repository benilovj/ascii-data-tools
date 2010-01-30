When /^record "([^\"]*)" coming from ([^\"]*) is analysed$/ do |ascii_text, record_source_name|
  record_source_name = nil if record_source_name == "unspecified"
  ascii_text.gsub!('\\n', "\n")
  type_determiner = AsciiDataTools::RecordType::TypeDeterminer.new(@record_types)
  @type = type_determiner.determine_type_for(ascii_text, record_source_name)
end

Then /^its type should be recognised as "([^\"]*)"$/ do |type_name|
  @type.name.should == type_name
end
