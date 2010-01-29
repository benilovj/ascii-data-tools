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

    describe Source do
      it "should be enumerable" do
        Source.new(nil, nil).should be_an(Enumerable)
      end
      
      it "should turn encoded records read from the input stream into records and yield them" do
        input_source = AsciiDataTools::InputSource.new("filename", StringIO.new("abc\ndef\n"))
        determiner = mock(AsciiDataTools::RecordType::TypeDeterminer)
        determiner.stub!(:determine_type_for).with("abc\n", "filename").and_return(mock(AsciiDataTools::RecordType::Type, :decode => "record abc"))
        determiner.stub!(:determine_type_for).with("def\n", "filename").and_return(mock(AsciiDataTools::RecordType::Type, :decode => "record def"))
        
        resultant_records = Source.new(input_source, determiner).collect {|r| r}
        resultant_records.should == ["record abc", "record def"]
      end      
    end
    
    describe Sink do
      it "should transform the received records and write them to the stream" do
        transformer = mock("record transformer")
        transformer.should_receive(:transform).with(anything).and_return("XYZ")
        output_stream = StringIO.new
        
        Sink.new(output_stream, transformer).receive(mock(Record))
        output_stream.string.should == "XYZ"
      end
      
      it "should flush and close the output stream when corresponding call is made" do
        output_stream = mock(IO)
        output_stream.should_receive(:flush).ordered
        output_stream.should_receive(:close).ordered
        
        Sink.new(output_stream, nil).flush_and_close
      end
    end

    describe Pipeline do
      it "should read records from a record source and write them to a record sink" do
        record_source = [mock(Record), mock(Record)]
        record_sink = mock(Sink)
        record_sink.should_receive(:receive).with(record_source.first).ordered
        record_sink.should_receive(:receive).with(record_source.last).ordered
        record_sink.should_receive(:flush_and_close).ordered
        
        Pipeline.new(record_source, record_sink).start_flow        
      end
    end
  end
end