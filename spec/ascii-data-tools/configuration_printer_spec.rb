require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'ascii-data-tools/configuration_printer'

module AsciiDataTools
  describe RecordTypesConfigurationPrinter do
    before do
      @presenter = mock(RecordTypesConfigurationPresenter,
        :headings => ["type name", "total length", "constraints", "normalised fields"],
        :record_type_summaries => [["x", "y", "z", "w"], ["a", "b", "c", "d"]]
      )
    end

    it "should print out the headers from the presenter" do
      RecordTypesConfigurationPrinter.new(@presenter).summary.should include("type name", "total length", "constraints", "normalised fields")
    end
    
    it "should print out the record type summaries" do
      RecordTypesConfigurationPrinter.new(@presenter).summary.should include("x", "y", "z", "w", "a", "b", "c", "d")
    end
  end
  
  describe RecordTypesConfigurationPresenter do
    include RecordTypeHelpers
    it "should provide headings" do
      RecordTypesConfigurationPresenter.new(nil).headings.should == ["type name", "total length", "constraints", "normalised fields"]
    end
    
    it "should present every record type as a row" do
      record_types = [type("ABC"), type("DEF")]
      RecordTypesConfigurationPresenter.new(record_types).record_type_summaries[0].should == ["ABC", 0, "", ""]
      RecordTypesConfigurationPresenter.new(record_types).record_type_summaries[1].should == ["DEF", 0, "", ""]
    end
    
    it "should sort the record types by the total length" do
      longer_record_type = type("longer") { field 'XYZ', :length => 5 }
      shorter_record_type = type("shorter") { field 'ABC', :length => 3 }
      record_types = [longer_record_type, shorter_record_type]
      RecordTypesConfigurationPresenter.new(record_types).record_type_summaries[0].first.should == "shorter"
      RecordTypesConfigurationPresenter.new(record_types).record_type_summaries[1].first.should == "longer"
    end
    
    it "should present the normalised fields" do
      record_types = [type("ABC") do
                        field 'yyy', :length => 1
                        field 'xxx', :length => 2, :normalised => true
                      end
                     ]
      RecordTypesConfigurationPresenter.new(record_types).record_type_summaries[0].should == ["ABC", 3, "", "xxx"]
    end
  end
end