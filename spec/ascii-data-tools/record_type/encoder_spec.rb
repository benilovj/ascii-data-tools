require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

module AsciiDataTools
  module RecordType
    module Encoder
      describe RecordEncoder do
        before do
          @type = Object.new
          @type.extend(RecordEncoder)
        end
        
        context "fixed length records" do
          it "should pack the values of fixed length records back together" do
            @type.encode(["123", "abc", "\n"]).should == "123abc\n"
          end
        end
      end
    end
  end
end