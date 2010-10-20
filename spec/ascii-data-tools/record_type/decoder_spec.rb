require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

module AsciiDataTools
  module RecordType
    module Decoder
      describe RecordDecoder do
        include RecordTypeHelpers
        before do
          @fields = [
            make_field("field100", :length => 3),
            make_field("field1",   :length => 5),
            make_field("field10",  :length => 1)
          ]
          @type = Struct.new(:content_fields, :fields_by_type).new(@fields, {:meta => fields do field(:filename, :constrained_to => /abc/) end})
          @type.extend(RecordTypeHelpers)
          @type.extend(RecordDecoder)
        end
      
        it "should know whether a given string is decodable" do
          @type.should be_able_to_decode(:ascii_string => "ABC12345\n")
        end
      
        it "should decode records correctly" do
          @type.decode(:ascii_string => "XYZ12345\n").values.should == ["XYZ", "12345", "\n"]
        end
      
        it "should take into account constraints that are set on the fields" do
          @type.content_fields[0].should_be_constrained_to("ABC")
          @type.should be_able_to_decode(:ascii_string => "ABC12345\n")
          @type.should_not be_able_to_decode(:ascii_string => "XYZ12345\n")
        end
      
        it "should not match ascii strings that don't have the same length as the individual fields" do
          @type.should_not be_able_to_decode(:ascii_string => "ABC1234\n")
          @type.should_not be_able_to_decode(:ascii_string => "ABC123456\n")
        end
        
        it "should not be able to decode if the filename field is not matching" do
          @type.should be_able_to_decode(:ascii_string => "ABC12345\n")
          @type.should be_able_to_decode(:ascii_string => "ABC12345\n", :filename => "abc")
          @type.should_not be_able_to_decode(:ascii_string => "ABC12345\n", :filename => "def")
        end
      end

      describe UnknownRecordDecoder do
        it "should decode the entire ascii string into the UNKNOWN field" do
          decoder = Struct.new(:field_names).new(["UNKNOWN"])
          decoder.extend(UnknownRecordDecoder)
          record = decoder.decode(:ascii_string => "any string\n")
          record["UNKNOWN"].should == "any string\n"
        end
      end
    end    
  end
end