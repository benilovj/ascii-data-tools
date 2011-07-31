require 'spec_helper'

module AsciiDataTools
  module RecordType
    module Encoder
      describe FixedLengthRecordEncoder do
        before do
          @type = Object.new
          @type.extend(FixedLengthRecordEncoder)
        end
        
        context "fixed length records" do
          it "should pack the values of fixed length records back together" do
            @type.encode(["123", "abc", "\n"]).should == "123abc\n"
          end
        end
      end

      describe CsvRecordEncoder do
        before do
          @type = Object.new
          @type.stub!(:field_with_name).with(:divider).and_return(mock("divider field", :value => ";"))
          @type.extend(CsvRecordEncoder)
        end
        
        it "should pack the values of csv records back together" do
          @type.encode(["123", "abc", "XYZ"]).should == "123;abc;XYZ\n"
        end
      end
    end
  end
end