require File.join(File.dirname(__FILE__), '..', 'spec_helper')

module AsciiDataTools
  module RecordType
    describe TypeWithFilenameRestrictions do
      include RecordTypeHelpers
      it "should match only when both the filename and field restrictions are satisfied" do
        type = type("ABC") do
          field 'f1', :length => 3
          field 'f2', :length => 1
        end.filename_should_match(/abc[.]gz/)
        
        type.should be_matching("XYZ\n", "abc.gz")
        type.should_not be_matching("XY\n", "abc.gz")
        type.should_not be_matching("XYZ\n", "xyz.gz")
        type.should_not be_matching("XXX\n", "xyz.gz")
      end
      
      it "can accept another filename restriction" do
        type = type("ABC").filename_should_match(/abc[.]gz/)
        type.should be_matching("", "abc.gz")
        
        type.filename_should_match(/xyz[.]gz/)
        type.should_not be_matching("", "abc.gz")
        type.should be_matching("", "xyz.gz")
      end
      
      describe "string representation" do
        it "should not provide a description of the filename constraints if none exists" do
          TypeWithFilenameRestrictions.new("ABC", []).constraints_description.should be_empty
        end
          
        it "should include the file constraint if one exists" do
          type = type("ABC").filename_should_match(/abc[.]gz/)
          
          type.constraints_description.should include('/abc[.]gz/')
        end
      end
    end
    
    describe Type do
      include RecordTypeHelpers
      it "should have a name" do
        type("ABC").name.should == "ABC"
      end
      
      context "(for fixed length records)" do
        before do
          @type = type("ABC") do
            field "field100", :length => 3
            field "field1",   :length => 5
            field "field10",  :length => 1
          end
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
        
        it "should decode records correctly" do
          @type.decode("XYZ12345\n").values.should == ["XYZ", "12345", "\n"]
        end
        
        it "should provide the total length of the fields" do
          @type.total_length_of_fields.should == 9
        end
        
        it "should provide an empty constraints description when there are no constraints" do
          @type.constraints_description.should be_empty
        end
        
        it "should encode values by just concatenating them" do
          @type.encode(["abc", "xyz", "\n"]).should == "abcxyz\n"
        end
        
        it "should provide a list of comma-delimited field constraints as the constraints description" do
          @type["field100"].should_be_constrained_to("ABC")
          @type.constraints_description.should == "field100 = ABC"
          
          @type["field10"].should_be_constrained_to("DEF")
          @type.constraints_description.should == "field100 = ABC, field10 = DEF"          
        end
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
        record = UnknownType.new.decode("any string\n")
        record["UNKNOWN"].should == "any string\n"
      end
    end
    
    describe TypeDeterminer do
      it "should determine the type that matches" do
        all_types = mock(RecordTypeRepository, :find_for_record => mock(Type, :name => "ABC"))
        TypeDeterminer.new(all_types).determine_type_for("any encoded record").name.should == "ABC"
      end
      
      it "should accept the context filename as an optional parameter" do        
        all_types = mock(RecordTypeRepository, :find_for_record => mock(Type, :name => "ABC"))
        TypeDeterminer.new(all_types).determine_type_for("any encoded record", "context filename").name.should == "ABC"
      end
      
      it "should determine the type to be unknown when no matching real type can be found" do
        TypeDeterminer.new(mock(RecordTypeRepository, :find_for_record => nil)).determine_type_for("any encoded record").should be_an(UnknownType)
      end
      
      it "should cache previously matched types and try to match them first" do
        first_type = mock("type 1")
        second_type = mock("type 2")
        
        all_types = mock(RecordTypeRepository)
        all_types.should_receive(:find_for_record).with("record 1", nil).ordered.and_return(first_type)

        determiner = TypeDeterminer.new(all_types)
        determiner.determine_type_for("record 1").should == first_type

        first_type.should_receive(:matching?).with("record 2", nil).once.ordered.and_return(false)

        all_types.should_receive(:find_for_record).with("record 2", nil).ordered.and_return(second_type)

        determiner.determine_type_for("record 2").should == second_type
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
        repo << mock(Type, :name => "ABC", :matching? => false) << mock(Type, :name => "DEF", :matching? => :true)
        repo.find_for_record("some record", "context").name.should == "DEF"
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