When /^ascii-data-edit is invoked$/ do
  AsciiDataTools::Controller::EditController.new(
    :input_sources        => [AsciiDataTools::InputSource.new(@record_source_filename, @input_stream)],
    :output_stream        => @output_stream,
    :record_types         => @record_types,
    :user_feedback_stream => @user_feedback_stream,
    :editor               => lambda do |filenames|
                               edited_file = File.new(filenames.first)
                               edited_file.extend(AsciiDataTools::ExternalPrograms)
                               @text_prior_to_edit = edited_file.read
                               File.open(edited_file.path, 'w') {|f| f << @text_after_edit}
                               edited_file.modify_file_mtime_to(Time.now + 1)
                             end
  ).run
end

When /^the output is successfully ascii\-edited to the following:$/ do |string|
  @text_after_edit = string
  When "ascii-data-edit is invoked"
end

When /^the output is ascii\-edited without alteration$/ do
  AsciiDataTools::Controller::EditController.new(
    :input_sources        => [AsciiDataTools::InputSource.new(@record_source_filename, @input_stream)],
    :output_stream        => @output_stream,
    :record_types         => @record_types,
    :user_feedback_stream => @user_feedback_stream,
    :editor               => lambda do |filenames| end
  ).run
end

Then /^the editor shows:$/ do |string|
  @text_prior_to_edit.should == string
end

Then /^the encoded record stream contains:$/ do |string|
  @output_stream.string.should == string
end