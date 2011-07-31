RSpec::Matchers.define :output do |expected_output|
  chain :from_upstream do |*filters|
    @filters = filters.map {|filter| filter.is_a?(String) ? input_source_containing(filter) : filter }
  end

  match do |filter|
    # connect upstream and downstream
    ([filter] + @filters).each_cons(2) {|downstream, upstream| downstream << upstream }
    output = StringIO.new
    
    filter.write(output)
    
    @actual_string = output.string
    output.string == expected_output
  end
  
  failure_message_for_should do |filter|
    "filter should output #{expected_output.inspect} but instead outputs #{@actual_string.inspect}"
  end
end

def input_source_containing(content)
  AsciiDataTools::InputSource.new("some file", StringIO.new(content))
end