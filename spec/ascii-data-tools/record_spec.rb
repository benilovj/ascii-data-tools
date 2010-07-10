require File.join(File.dirname(__FILE__), '..', 'spec_helper')

module AsciiDataTools
  module Record
    describe Record do
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
      
      it "should raise an error when trying to access a non-existing field" do
        lambda {Record.new(mock(AsciiDataTools::RecordType::Type, :field_names => ["existing"]), ["xyz"])['non-existing'] }.should raise_error(/non-existing.*does not exist/)
      end
    end
  end
end