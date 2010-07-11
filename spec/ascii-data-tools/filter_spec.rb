require File.join(File.dirname(__FILE__), '..', 'spec_helper')

require 'ascii-data-tools/configuration'
require 'ascii-data-tools/filter'
require 'stringio'

Spec::Matchers.define :output do |expected_output|
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

module AsciiDataTools
  module Filter
    describe Filter do
      it "should read from 'upstream' and filter when reading" do
        filter = Filter.new do |record|
          record.strip.reverse + "\n"
        end
        filter << mock("upstream object", :read => "abc\n")
        
        filter.read.should == "cba\n"
      end
      
      it "should read from upstream and write to given output" do
        Filter.new do |record|
          record.strip.reverse + "\n"
        end.should output("cba\nfed\n").from_upstream("abc\ndef\n")
      end
      
      it "should be chainable" do
        first_filter = Filter.new do |record|
          (record.strip.to_i * 2).to_s + "\n"
        end
        Filter.new do |record|
          (record.strip.to_i + 3).to_s + "\n"
        end.should output("5\n7\n").from_upstream(first_filter, "1\n2\n")
      end
    end
    
    describe BufferingFilter do
      it "should buffer the upstream into a tempfile before the first read and then return it" do
        BufferingFilter.new do |buffered_upstream_as_tempfile|
          buffered_upstream_as_tempfile
        end.should output("abc\ndef\n").from_upstream("abc\ndef\n")
      end
      
      it "should be chainable" do
        first_filter = BufferingFilter.new do |tempfile|
          StringIO.new(tempfile.readlines.map {|s| s.upcase}.join(""))
        end
        BufferingFilter.new do |tempfile|
          StringIO.new(tempfile.readlines.map {|s| s.strip + "n" + "\n" }.join(""))
        end.should output("ABCn\nDEFn\n").from_upstream(first_filter, "abc\ndef\n")
      end
    end
    
    describe SortingFilter do
      it "should sort the given stream" do
        should output("abc\ndef\nxyz\n").from_upstream("xyz\nabc\ndef\n")
      end
    end
    
    describe DiffingFilter do
      it "should return an empty result if the inputs are the same" do
        should output("").from_upstream([input_source_containing("abc\ndef\nxyz\n"), input_source_containing("abc\ndef\nxyz\n")])
      end
      
      it "should return the diff if the inputs are not the same" do
        should output("2a3\n> xyz\n").from_upstream([input_source_containing("abc\ndef\n"), input_source_containing("abc\ndef\nxyz\n")])
      end
    end
  end
end