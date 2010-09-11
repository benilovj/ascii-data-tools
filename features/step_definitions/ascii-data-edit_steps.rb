When /^ascii-data-edit is invoked$/ do
  AsciiDataTools::Controller::EditController.new(
    :input_sources => [AsciiDataTools::InputSource.new(@record_source_filename, @input_stream)],
    :output_stream => @output_stream,
    :record_types  => @record_types,
    :editor        => lambda do |filenames|
                        edited_filename = filenames.first
                        @text_prior_to_edit = File.read(edited_filename)
                        File.open(edited_filename, 'w') {|f| f << @text_after_edit}
                      end
  ).run
end

When /^the output is successfully ascii\-edited to the following:$/ do |string|
  @text_after_edit = string
  When "ascii-data-edit is invoked"
end

Then /^the editor shows:$/ do |string|
  @text_prior_to_edit.should == string
end

Then /^the encoded record stream contains:$/ do |string|
  @output_stream.string.should == string
end