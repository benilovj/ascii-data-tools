require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'filter_helper')

require 'ascii-data-tools/configuration'
require 'ascii-data-tools/filter'
require 'stringio'

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
        f1 = Filter.new {|r| r.gsub(/\d/, "X") }
        f2 = Filter.new {|r| r.count("X").to_s }
        f3 = Filter.new {|r| r }

        f3 << (f2 << (f1 << input_source_containing("ab1cd2")))
        f3.read.should == "2"
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
    
    DECODED_FIXED_LENGTH_RECORD = <<STR
Record 01 (ABC)
01 field1  : [12345]-----
02 field10 : [abc]-------
03 field3  : [\\n]--------

STR
    
    SEVERAL_FIXED_LENGTH_RECORDS = <<STR
Record 01 (unknown)
01 UNKNOWN  : [12345]-----

Record 02 (unknown)
01 UNKNOWN  : [abc]-----

STR
    
    describe ParsingFilter do
      include RecordTypeHelpers
      include AsciiDataTools::Record
      include AsciiDataTools::RecordType
      it "should identify a decoded record and encode it" do
        type = type("ABC") do
          field 'field1',  :length => 5
          field 'filed10', :length => 3
          field 'field3',  :length => 1
        end
        record_types = mock(AsciiDataTools::RecordType::RecordTypeRepository)
        record_types.should_receive(:find_by_name).with("ABC").and_return(type)
        
        filter = ParsingFilter.new(record_types)
        filter << input_source_containing(DECODED_FIXED_LENGTH_RECORD)
        filter.read.should == Record.new(type, ["12345", "abc", "\n"])
      end
      
      it "should identify a decoded record and encode it" do
        type = UnknownType.new
        record_types = mock(AsciiDataTools::RecordType::RecordTypeRepository)
        record_types.should_receive(:find_by_name).with("unknown").twice.and_return(type)
        
        filter = ParsingFilter.new(record_types)
        filter << input_source_containing(SEVERAL_FIXED_LENGTH_RECORDS)
        filter.read.should == Record.new(type, ["12345"])
        filter.read.should == Record.new(type, ["abc"])
      end
    end
  end
end