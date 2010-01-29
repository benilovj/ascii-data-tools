require File.join(File.dirname(__FILE__), '..', 'spec_helper')

module AsciiDataTools
  describe Configuration do
    it "should allow overwriting the input source and output stream" do
      input_source = mock("input source")
      output_stream = mock("output stream")
      config = Configuration.new([], {:input_source => input_source, :output_stream => output_stream, :record_types => "record types"})
      config.output_stream.should == output_stream
      config.input_source.should == input_source
    end
    
    it "should not be valid unless the input stream is specified" do
      config = Configuration.new([], :record_types => "record types")
      config.should_not be_valid
      config.errors.should include("No input specified.")
    end
    
    it "should accept existing flat files as input" do
      File.stub!(:exists?).with("path/to/file").and_return(true)
      File.should_receive(:open).with("path/to/file").and_return(mock(IO))
      
      config = Configuration.new(["path/to/file"], :record_types => "record types")
      config.should be_valid
    end
    
    it "should reject non-existing flat files as input" do
      File.stub!(:exists?).with("path/to/file").and_return(false)
      config = Configuration.new(["path/to/file"], :record_types => "record types")
      config.should_not be_valid
      config.errors.should include("File path/to/file does not exist!")
    end
    
    it "should exit when passed invalid options" do
      config = Configuration.new(["-xxx"], :record_types => "record types")
      config.should_not be_valid
      config.errors.should include("invalid option: -xxx")
    end
    
    it "should load record types using autodiscovery by default" do
      AsciiDataTools.should_receive(:autodiscover).once
      AsciiDataTools.stub!(:record_types).and_return("record types")      
      Configuration.new([]).record_types.should == "record types"
    end
    
    it "should use the override for record types if specified" do
      AsciiDataTools.should_receive(:autodiscover).exactly(0).times
      Configuration.new([], :record_types => "overriden record types").record_types.should == "overriden record types"
    end
  end
  
  describe InputSourceFactory do
    it "should use STDIN as the stream when - is the input argument" do
      InputSourceFactory.new(["-"]).input_source.stream.should == STDIN
    end
    
    it "should raise an error if the path specified in the input argument does not exist" do
      lambda { InputSourceFactory.new(["path/to/non-existent-file"]).input_source }.should raise_error(/does not exist/)
    end
    
    it "should raise an error if the input parameters are empty" do
      lambda { InputSourceFactory.new([]).input_source }.should raise_error(/No input specified/)      
    end

    it "should raise an error if more than one input parameter is specified" do
      lambda { InputSourceFactory.new(["x", "y"]).input_source }.should raise_error(/Two input sources detected/i)      
    end
    
    it "should open the file normally if the path specified in the input argument exists and the file is not gzipped" do
      File.stub!(:exists?).with("path/to/file").and_return(true)
      File.should_receive(:open).with("path/to/file").and_return("IO stream")
      
      InputSourceFactory.new(["path/to/file"]).input_source.stream.should == "IO stream"
    end
    
    it "should open the file as a gzip read stream if the path specified in the input argument exists and the file is gzipped" do
      File.stub!(:exists?).with("path/to/file.gz").and_return(true)
      Zlib::GzipReader.should_receive(:open).with("path/to/file.gz").and_return("IO stream")
      
      InputSourceFactory.new(["path/to/file.gz"]).input_source.stream.should == "IO stream"
    end
  end
end