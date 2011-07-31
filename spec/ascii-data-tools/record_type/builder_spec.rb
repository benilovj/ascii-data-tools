require 'spec_helper'

module AsciiDataTools
  module RecordType
    module Builder
      describe TypeBuilder do
        include TypeBuilder
        it "should create a type with the given name" do
          build_type("ABC").name.should == "ABC"
        end

        it "should create a type which matches only for specific filenames (if given)" do
          type = build_type("ABC", :applies_for_filenames_matching => /ABC/)
          type.should be_able_to_decode(:ascii_string => "", :filename => "ABC.gz")
          type.should_not be_able_to_decode(:ascii_string => "", :filename => "XYZ.gz")
        end

        context "for fixed-length types" do
          before do
            @record_type = build_type("ABC") do
              field "RECORD_TYPE",   :length => 3,  :constrained_to => "ABC"
              field "A_NUMBER",      :length => 16, :constrained_to => /123/
              field "RECORD_NUMBER", :length => 5,  :normalised => true
              field "END_OF_RECORD", :length => 1
            end
          end

          it "should really build a fixed-length type" do
            @record_type.should be_a(AsciiDataTools::RecordType::FixedLengthType)
          end

          it "should have the correct fields" do
            @record_type.field_names.should == ["RECORD_TYPE", "A_NUMBER", "RECORD_NUMBER", "END_OF_RECORD"]
          end

          it "should have the correct length" do
            @record_type.total_length_of_fields.should == 25
          end

          it "should have the correct constraints" do
            @record_type.constraints_description.should == "RECORD_TYPE = ABC, A_NUMBER =~ /123/"
          end
        
          it "should normalise fields" do
            @record_type.field_with_name("RECORD_NUMBER").should be_normalised
          end
        end
      
        context "for csv types" do
          before do
            @record_type = build_type("ABC", :family => "csv", :divider => ";") do
              field "RECORD_TYPE"
              field "A_NUMBER"
              field "RECORD_NUMBER"
            end
          end
          
          it "should really build a csv type" do
            @record_type.should be_a(AsciiDataTools::RecordType::CsvType)
          end
          
          it "should save the divider" do
            @record_type.field_with_name(:divider).value.should == ";"
          end
        end
      end
    end
  end
end