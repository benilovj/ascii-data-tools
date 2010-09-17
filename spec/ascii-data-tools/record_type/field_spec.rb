require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

module AsciiDataTools
  module RecordType
    module Field
      describe Field do
        it "should have a name" do
          Field.new("name").name.should == "name"
        end
      
        context "a constrained field" do
          it "should provide a text description of the constraint" do
            field = Field.new("name")
            field.should_be_constrained_to("abc")
            field.constraint_description.should == "name = abc"
          end
        end
      end
    
      describe FixedLengthField do
        it "should have a name" do
          FixedLengthField.new("name", nil).name.should == "name"
        end
      
        it "should contribute to the regexp string used for type matching" do
          FixedLengthField.new(nil, 5).extend_regexp_string_for_matching("xxx").should == "xxx(.{5})"
        end
      
        it "should let the constraint contribute to the regexp string used for type matching if it is set" do
          field = FixedLengthField.new(nil, 5)
          field.constraint = mock("field constraint", :extend_regexp_string_for_matching => "xxxabc")
          field.extend_regexp_string_for_matching("xxx").should == "xxxabc"
        end      
      end
    
      describe FixedLengthConstraint do
        it "should contribute to a regexp string by limiting the number of characters" do
          FixedLengthConstraint.new(5).extend_regexp_string_for_matching('xxx').should == "xxx(.{5})"
        end
      
        it "should have an empty string representation" do
          FixedLengthConstraint.new(5).to_s.should be_empty
        end
      end
    
      describe OneOfConstraint do
        it "should contribute to a regexp string that matches the type" do
          OneOfConstraint.new("ABC", "DEF", "XYZ").extend_regexp_string_for_matching("xxx").should == "xxx(ABC|DEF|XYZ)"
        end
      
        it "should have the appropriate string representation when there is one possible value" do
          OneOfConstraint.new("ABC").to_s.should == "= ABC"
        end

        it "should have the appropriate string representation when there is more than one value possible" do
          OneOfConstraint.new(["ABC", "DEF"]).to_s.should == "one of ABC, DEF"
        end
      end
    
      describe RegexpConstraint do
        it "should contribute to a regexp string that matches the type" do
          RegexpConstraint.new(/A\d{3}C/).extend_regexp_string_for_matching("xxx").should == "xxxA\\d{3}C"
        end
      
        it "should be satisfied when the string passed to it matches its regexp" do
          RegexpConstraint.new(/ABC/).should be_satisfied_by("xyz.ABC.gz")
          RegexpConstraint.new(/ABC/).should_not be_satisfied_by("xyz.UVW.gz")
        end
      
        it "should have an appropriate string representation" do
          RegexpConstraint.new(/ABC/).to_s.should == "=~ /ABC/"
        end
      end
    
      describe FilenameConstraint do
        context "by default" do
          it "should match any filename" do
            should be_satisfied_by("abc")
            should be_satisfied_by("XXX")
            should be_satisfied_by(nil)
          end
        
          it "should be represented by an empty string" do
            FilenameConstraint.new.to_s.should be_empty
          end
        end
      
        context "when defined" do
          it "should print the regexp in the string representation" do
            FilenameConstraint.satisfied_by_filenames_matching(/ABC[.]\d\d[.]gz/).to_s.should == 'Filename =~ /ABC[.]\d\d[.]gz/'
          end
        
          it "should be satisfied by correctly-named filenames" do
            constraint = FilenameConstraint.satisfied_by_filenames_matching(/ABC[.]\d\d[.]gz/)
            constraint.should be_satisfied_by("ABC.12.gz")
            constraint.should_not be_satisfied_by("ABC.123.gz")
            constraint.should_not be_satisfied_by(nil)
          end
        end
      end
    end
  end
end