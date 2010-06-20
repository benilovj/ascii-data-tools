When /^ascii\-data\-norm is invoked$/ do
  configuration = AsciiDataTools::Configuration.new(@command_line,
    :input_sources => [AsciiDataTools::InputSource.new(@record_source_filename, @input_stream)],
    :output_stream => @output_stream,
    :record_types  => @record_types
  )

  AsciiDataTools::Controller::NormalisationController.new(configuration).run
end
