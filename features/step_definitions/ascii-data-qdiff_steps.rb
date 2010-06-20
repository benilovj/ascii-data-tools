Given /^streams containing$/ do |text|
  @input_stream1 = StringIO.new
  @input_stream2 = StringIO.new
  
  text.split("\n").each do |line|
    left_line, right_line = line.split("||").map(&:strip)
    @input_stream1 << left_line.gsub('\n', "\n") unless left_line == "-" * left_line.length and not left_line.empty?
    @input_stream2 << right_line.gsub('\n', "\n") unless right_line == "-" * right_line.length and not right_line.empty?
  end
  @input_stream1.rewind
  @input_stream2.rewind
end

When /^ascii\-data\-qdiff is invoked on files containing:$/ do |string|
  Given "streams containing", string
  When "ascii-data-qdiff is invoked"
end

When /^ascii\-data\-qdiff is invoked$/ do
  @actual_output1 = @actual_output2 = nil
  AsciiDataTools::Controller::DiffController.new(
    :input_sources  => [AsciiDataTools::InputSource.new(nil, @input_stream1),
                        AsciiDataTools::InputSource.new(nil, @input_stream2)],
    :differ         => lambda do |filenames|
                         @actual_output1 = File.read(filenames.first)
                         @actual_output2 = File.read(filenames.last)
                       end,
    :record_types   => @record_types
  ).run
end

Then /^the diffed result should be:$/ do |text|
  expected_output1, expected_output2 = "", ""
  text.split("\n").each do |line|
    left_line, right_line = line.split("||").map(&:strip)
    expected_output1 << left_line + "\n" unless left_line == "-" * left_line.length and not left_line.empty?
    expected_output2 << right_line + "\n" unless right_line == "-" * right_line.length and not right_line.empty?
  end
  @actual_output1.should == expected_output1
  @actual_output2.should == expected_output2
end