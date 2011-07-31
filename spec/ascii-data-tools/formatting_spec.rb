require 'spec_helper'

EXPECTED_FORMATTING_OF_FIXED_LENGTH_RECORD = <<STR
Record 01 (ABC)
01 field1  : [12345]-----
02 field10 : [abc]-------
03 field3  : [\\n]--------

STR

EXPECTED_FORMATTING_OF_UNNUMBERED_FIXED_LENGTH_RECORD = <<STR
Record (ABC)
01 field1  : [12345]-----
02 field10 : [abc]-------
03 field3  : [\\n]--------

STR

include RecordTypeHelpers

def fixed_length_type
  type("ABC") do
    field 'field1',  :length => 5
    field 'field10', :length => 3
    field 'field3',  :length => 1
  end
end

module AsciiDataTools
  module Formatting
    describe Formatter do
      it "should format a fixed-length record" do
        record = AsciiDataTools::Record::Record.new(fixed_length_type, ["12345", "abc", "\n"])
        Formatter.new.format(record).should == EXPECTED_FORMATTING_OF_FIXED_LENGTH_RECORD
      end
    end
    
    describe FormatableType do
      include RecordTypeHelpers
      before do
        @fields = [
          make_field("field1",  :length => 5),
          make_field("field10", :length => 3),
          make_field("field3",  :length => 1)
        ]
        @type = Struct.new(:name, :fields, :length_of_longest_field_name).new("ABC", @fields, 7)
        @type.extend(FormatableType)
      end
      
      it "should format values" do
        @type.format(1, ["12345", "abc", "\n"]).should == EXPECTED_FORMATTING_OF_FIXED_LENGTH_RECORD
      end
    end
    
    describe FormatableField do
      include RecordTypeHelpers
      before do
        @field = make_field("field1", :length => 5)
        @field.extend(FormatableField)
      end
      
      it "should make a template for the longest field" do
        @field.template(:position => 3, :longest_field_name => 7, :longest_field_length => 5).should == "03 field1  : [%s]-----"
      end

      it "should make a template for fields that are not the longest" do
        @field.template(:position => 3, :longest_field_name => 7, :longest_field_length => 7).should == "03 field1  : [%s]-------"
      end

      it "should make a template for the last field (which has a newline in it)" do
        field = make_field("NEWLINE",  :length => 1)
        field.extend(FormatableField)
        field.template(:position => 3,
                       :longest_field_name => 7,
                       :longest_field_length => 2,
                       :last_field? => true).should == "03 NEWLINE : [%s]-----"
      end
      
      it "should make a template for fields without lengths" do
        field = mock("field", :name => "ABC")
        field.extend(FormatableField)
        field.template(:position => 3,
                       :longest_field_name => 3,
                       :longest_field_length => 2).should == "03 ABC : [%s]-----"
      end
    end
    
    describe UnnumberedFormatableType do
      include RecordTypeHelpers
      before do
        @fields = [
          make_field("field1",  :length => 5),
          make_field("field10", :length => 3),
          make_field("field3",  :length => 1)
        ]
        @type = Struct.new(:name, :fields, :length_of_longest_field_name).new("ABC", @fields, 7)
        @type.extend(UnnumberedFormatableType)
      end
      
      it "should format a record" do
        # record = AsciiDataTools::Record::Record.new(fixed_length_type, ["12345", "abc", "\n"])
        @type.format(1, ["12345", "abc", "\n"]).should == EXPECTED_FORMATTING_OF_UNNUMBERED_FIXED_LENGTH_RECORD
      end
    end
  end
end