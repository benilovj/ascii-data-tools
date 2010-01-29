require File.join(File.dirname(__FILE__), '..', 'spec_helper')

EXPECTED_FORMATTING_OF_FIXED_LENGTH_RECORD = <<STR
Record 01 (ABC)
01 field1  : [12345]-----
02 field10 : [abc]-------
03 field3  : [\\n]--------

STR

include RecordTypeHelpers

def fixed_length_type
  type("ABC").with(
    fixed_length_field("field1", 5),
    fixed_length_field("field10", 3),
    fixed_length_field("field3", 1)
  ).build
end

module AsciiDataTools
  module Formatting
    describe Formatter do
      it "should format a fixed-length record" do
        # fixed_length_type = 
        record = AsciiDataTools::Record::Record.new(fixed_length_type, ["12345", "abc", "\n"])
        Formatter.new.format(record).should == EXPECTED_FORMATTING_OF_FIXED_LENGTH_RECORD
      end
    end

    describe TypeTemplate do
      include RecordTypeHelpers
      it "should format a record" do
        record = AsciiDataTools::Record::Record.new(fixed_length_type, ["12345", "abc", "\n"])
        TypeTemplate.new(fixed_length_type).format(1, record).should == EXPECTED_FORMATTING_OF_FIXED_LENGTH_RECORD
      end
    end
  end
end