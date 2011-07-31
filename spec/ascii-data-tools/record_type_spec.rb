require 'spec_helper'

module AsciiDataTools
  module RecordType
    describe Type do
      include RecordTypeHelpers
      
      before do
        @type = type("ABC") do
          field "field100"
          field "field1"
          field "field10"
        end
      end
      
      it "should have a name" do
        @type.name.should == "ABC"
      end
      
      it "should provide the field names" do
        @type.field_names.should == ["field100", "field1", "field10"]
      end
      
      it "should provide the number of content fields" do
        @type.number_of_content_fields.should == 3
      end
      
      it "should provide the length of the field with the longest name" do
        @type.length_of_longest_field_name.should == 8
      end
      
      it "should provide an empty constraints description when there are no constraints" do
        @type.constraints_description.should be_empty
      end
      
      it "should provide a list of comma-delimited field constraints as the constraints description" do
        @type.field_with_name("field100").should_be_constrained_to("ABC")
        @type.constraints_description.should == "field100 = ABC"
        
        @type.field_with_name("field10").should_be_constrained_to("DEF")
        @type.constraints_description.should == "field100 = ABC, field10 = DEF"          
      end
      
      it "should have an inbuilt filename meta field" do
        @type.field_with_name(:filename).should_not be_nil
      end
      
      it "should provide a shortcut for constraining the filename" do
        @type.filename_should_match /abc/
        @type.field_with_name(:filename).constraint_description.should == "filename =~ /abc/"
      end
    end
    
    describe FixedLengthType do
      include RecordTypeHelpers
      
      before do
        @type = type("ABC") do
          field "field100", :length => 3
          field "field1",   :length => 5
          field "field10",  :length => 1
        end
      end
      
      it "should provide the total length of the fields" do
        @type.total_length_of_fields.should == 9
      end
    end
    
    describe UnknownType do
      it "should provide the name" do
        UnknownType.new.name.should == UnknownType::UNKNOWN_RECORD_TYPE_NAME
      end
      
      it "should have one field (UNKNOWN)" do
        UnknownType.new.field_names.should == ["UNKNOWN"]
      end
      
      it "should decode the entire ascii string into the UNKNOWN field" do
        record = UnknownType.new.decode(:ascii_string => "any string\n")
        record["UNKNOWN"].should == "any string\n"
      end
    end
    
    describe TypeDeterminer do
      it "should determine the type that matches" do
        all_types = mock(RecordTypeRepository, :identify_type_for => mock(Type, :name => "ABC"))
        TypeDeterminer.new(all_types).determine_type_for(:ascii_string => "any encoded record").name.should == "ABC"
      end
      
      it "should accept the context filename as an optional parameter" do        
        all_types = mock(RecordTypeRepository, :identify_type_for => mock(Type, :name => "ABC"))
        TypeDeterminer.new(all_types).determine_type_for(:ascii_string => "any encoded record", :filename => "context filename").name.should == "ABC"
      end
      
      it "should determine the type to be unknown when no matching real type can be found" do
        TypeDeterminer.new(mock(RecordTypeRepository, :identify_type_for => nil)).determine_type_for(:ascii_string => "any encoded record").should be_an(UnknownType)
      end
      
      it "should cache previously matched types and try to match them first" do
        first_type = mock("type 1")
        second_type = mock("type 2")
        
        all_types = mock(RecordTypeRepository)
        all_types.should_receive(:identify_type_for).with(:ascii_string => "record 1").ordered.and_return(first_type)

        determiner = TypeDeterminer.new(all_types)
        determiner.determine_type_for(:ascii_string => "record 1").should == first_type

        first_type.should_receive(:able_to_decode?).with(:ascii_string => "record 2").once.ordered.and_return(false)

        all_types.should_receive(:identify_type_for).with(:ascii_string => "record 2").ordered.and_return(second_type)

        determiner.determine_type_for(:ascii_string => "record 2").should == second_type
      end
    end
    
    describe RecordTypeRepository do
      it "should be enumerable" do
        should be_a_kind_of(Enumerable)
      end
      
      it "should have a reset switch" do
        repo = RecordTypeRepository.new
        repo << mock(Type, :name => "ABC") << mock(Type, :name => "DEF")
        repo.clear
        repo.type("ABC").should be_nil
        repo.type("DEF").should be_nil        
      end
      
      it "should find record types by name" do
        repo = RecordTypeRepository.new
        repo << mock(Type, :name => "ABC") << mock(Type, :name => "DEF")
        repo.find_by_name("ABC").name.should == "ABC"
        repo.type("ABC").name.should == "ABC"
        repo.find_by_name("XYZ").should be_nil
      end
      
      it "should find record types which match a certain record" do
        repo = RecordTypeRepository.new
        repo << mock(Type, :name => "ABC", :able_to_decode? => false) << mock(Type, :name => "DEF", :able_to_decode? => :true)
        repo.identify_type_for(:ascii_string => "some record", :filename => "context").name.should == "DEF"
      end
      
      it "should store each type only once" do
        type = mock(Type)
        repo = RecordTypeRepository.new([type, type])
        repo.map {|type| type}.should have(1).item
      end
      
      it "should find types by name" do
        repo = RecordTypeRepository.new
        repo << mock(Type, :name => "ABC") << mock(Type, :name => "DEF") << mock(Type, :name => "XYZ")
        found_type_names = []
        repo.for_names_matching(/ABC|DEF/) {|type| found_type_names << type.name}
        found_type_names.sort.should == ["ABC", "DEF"]
      end
      
      it "should find types by name using a block" do
        repo = RecordTypeRepository.new
        repo << mock(Type, :name => "ABC") << mock(Type, :name => "DEF") << mock(Type, :name => "XYZ")
        found_type_names = []
        matcher = lambda {|name| ["ABC", "DEF"].include?(name) }
        repo.for_names_matching(matcher) {|type| found_type_names << type.name}
        found_type_names.sort.should == ["ABC", "DEF"]        
      end
      
      it "should include the builder for new types for convenience" do
        repo = RecordTypeRepository.new
        repo.record_type("ABC") { field "xyz", :length => 3 }
        repo.type("ABC").number_of_content_fields.should == 1
      end
    end    
  end
end