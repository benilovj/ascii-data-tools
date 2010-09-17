require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

module AsciiDataTools
  module RecordType
    module Normaliser
      describe Normaliser do
        include RecordTypeHelpers
        before do
          @fields = [
             make_field("field1", :length => 3),
             make_field("field2", :length => 5, :normalised => true),
             make_field("field3", :length => 3, :normalised => true),
             make_field("field4", :length => 1)
           ]
           @type = Struct.new(:fields).new(@fields)
           @type.extend(Normaliser)
        end

        it "should X out the characters in fields configured for normalisation" do
          @type.normalise("123ABCDEXYZ\n").should == "123XXXXXXXX\n"
        end
      end
    end
  end
end