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
    
    describe TransformingPipeline do
      it "should read input records, transform them and write them to the output" do
        input_source = AsciiDataTools::InputSource.new("filename", StringIO.new("abc\ndef\n"))
        output = StringIO.new        
        pipeline = TransformingPipeline.new {|record, filename| "#{filename}:#{record.strip.reverse}\n"}

        pipeline.stream(input_source, output)

        output.string.should == "filename:cba\nfilename:fed\n"
      end
    end
    
    describe Filter do
      it "should read from 'upstream' and filter when reading" do
        filter = Filter.new do |record|
          record.strip.reverse + "\n"
        end
        filter << mock("upstream object", :read => "abc\n")
        
        filter.read.should == "cba\n"
      end
      
      it "should read from upstream and write to given output" do
        filter = Filter.new do |record|
          record.strip.reverse + "\n"
        end
        filter << InputSource.new("some file", StringIO.new("abc\ndef\n"))
        output = StringIO.new
        
        filter.write(output)

        output.string.should == "cba\nfed\n"
      end
      
      it "should be chainable" do
        first_filter = Filter.new do |record|
          (record.strip.to_i * 2).to_s + "\n"
        end
        second_filter = Filter.new do |record|
          (record.strip.to_i + 3).to_s + "\n"
        end
        second_filter << first_filter << InputSource.new("some file", StringIO.new("1\n2\n"))
        output = StringIO.new
        
        second_filter.write(output)

        output.string.should == "5\n7\n"
      end
    end
    
    describe BufferingFilter do
      it "should buffer the upstream into a tempfile before the first read and then return it" do
        buffering_filter = BufferingFilter.new do |buffered_upstream_as_tempfile|
          buffered_upstream_as_tempfile
        end
        
        buffering_filter << InputSource.new("some file", StringIO.new("abc\ndef\n"))
        output = StringIO.new
        
        buffering_filter.write(output)
        
        output.string.should == "abc\ndef\n"
      end
      
      it "should be chainable" do
        first_filter = BufferingFilter.new do |tempfile|
          StringIO.new(tempfile.readlines.map {|s| s.upcase}.join(""))
        end
        second_filter = BufferingFilter.new do |tempfile|
          StringIO.new(tempfile.readlines.map {|s| s.strip + "n" + "\n" }.join(""))
        end
        second_filter << first_filter << InputSource.new("some file", StringIO.new("abc\ndef\n"))
        output = StringIO.new
        
        second_filter.write(output)

        output.string.should == "ABCn\nDEFn\n"
      end
    end
  end
end