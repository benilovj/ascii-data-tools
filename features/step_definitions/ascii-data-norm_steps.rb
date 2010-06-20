When /^ascii\-data\-norm is invoked$/ do
  AsciiDataTools::Controller::NormalisationController.new(
    :input_sources => [AsciiDataTools::InputSource.new(@record_source_filename, @input_stream)],
    :output_stream => @output_stream,
    :record_types  => @record_types
  ).run
end
