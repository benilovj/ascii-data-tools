require File.join(File.dirname(__FILE__), '..', 'spec_helper')

module AsciiDataTools
  module Record
    describe Record do
      include AsciiDataTools::RecordType
      it "should provide the type name" do
        Record.new(mock(AsciiDataTools::RecordType::Type, :name => "ABC"), nil).type_name.should == "ABC"
      end

      it "should provide access to its contents" do
        record = Record.new(mock(AsciiDataTools::RecordType::Type, :field_names => ["field1", "field2"]), ["xyz", "abc"])
        record["field1"].should == "xyz"
        record["field2"].should == "abc"        
      end
      
      it "should be representable as an array" do
        Record.new(mock(AsciiDataTools::RecordType::Type, :field_names => ["field1", "field2"]), ["xyz", "abc"]).to_a.should == [
          ["field1", "xyz"],
          ["field2", "abc"]
        ]
      end
      
      it "should have a string representation which includes the type name and key-value pairs" do
        record_type = mock(AsciiDataTools::RecordType::Type, :name => "ABC", :field_names => ["field1", "field2"])
        Record.new(record_type, ["xyz", "\n"]).to_s.should == 'ABC: field1 => "xyz", field2 => "\n"'
      end
      
      it "should defer encoding to the record type" do
        type = mock(AsciiDataTools::RecordType::Type)
        type.should_receive(:encode).with(["abc", "xyz"]).and_return("encoded string")
        Record.new(type, ["abc", "xyz"]).encode.should == "encoded string"
      end
      
      it "should be comparable to other records" do
        type = mock(AsciiDataTools::RecordType::Type, :field_names => ["field1", "field2"])
        another_type = mock(AsciiDataTools::RecordType::Type, :field_names => ["field1", "field3"])
        
        Record.new(type, ["abc", "def"]).should == Record.new(type, ["abc", "def"])
        Record.new(type, ["abc", "def"]).should_not == Record.new(another_type, ["abc", "def"])
        Record.new(type, ["abc", "def"]).should_not == Record.new(type, ["abc", "xyz"])
      end
      
      it "should raise an error when trying to access a non-existing field" do
        lambda {Record.new(mock(AsciiDataTools::RecordType::Type, :field_names => ["existing"]), ["xyz"])['non-existing'] }.should raise_error(/non-existing.*does not exist/)
      end
    end
  end
end