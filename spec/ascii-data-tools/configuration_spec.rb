require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'stringio'

module AsciiDataTools
  describe Configuration do
    it "should allow overwriting the input source, output stream, record types and user feedback stream" do
      input_source = mock("input source")
      output_stream = mock("output stream")
      config = Configuration.new([], {:input_sources => [input_source],
                                      :output_stream => output_stream,
                                      :record_types => "record types",
                                      :user_feedback_stream => "user feedback stream"})
      config.output_stream.should == output_stream
      config.input_sources.should == [input_source]
      config.record_types.should == "record types"
      config.user_feedback_stream.should == "user feedback stream"
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
      source_from(["-"]).stream.should == STDIN
    end
    
    it "should raise an error if the path specified in the input argument does not exist" do
      lambda { source_from(["path/to/non-existent-file"]) }.should raise_error(/does not exist/)
    end
    
    it "should raise an error if the input parameters are empty" do
      lambda { source_from([]) }.should raise_error(/No input specified/)      
    end

    it "should raise an error if the wrong number of input parameters is specified" do
      lambda { source_from(["x", "y"]) }.should raise_error(/2 input sources detected/i)      
    end
    
    it "should process multiple input sources if so configured" do
      File.stub!(:exists?).with("path/to/file1").and_return(true)
      File.should_receive(:open).with("path/to/file1").and_return("IO stream 1")
      File.stub!(:exists?).with("path/to/file2").and_return(true)
      File.should_receive(:open).with("path/to/file2").and_return("IO stream 2")
      
      factory = InputSourceFactory.new(:expected_argument_number => 2)
      sources = factory.input_sources_from ["path/to/file1", "path/to/file2"]
      sources[0].stream.should == "IO stream 1"
      sources[1].stream.should == "IO stream 2"      
    end
    
    it "should reject the input pipe as an argument if so configured" do
      lambda { InputSourceFactory.new(:input_pipe_accepted => false).input_sources_from(["-"]) }.should raise_error /STDIN/
    end
    
    it "should open the file normally if the path specified in the input argument exists and the file is not gzipped" do
      File.stub!(:exists?).with("path/to/file").and_return(true)
      File.should_receive(:open).with("path/to/file").and_return("IO stream")
      
      source_from(["path/to/file"]).stream.should == "IO stream"
    end
    
    it "should open the file as a gzip read stream if the path specified in the input argument exists and the file is gzipped" do
      File.stub!(:exists?).with("path/to/file.gz").and_return(true)
      Zlib::GzipReader.should_receive(:open).with("path/to/file.gz").and_return("IO stream")
      
      source_from(["path/to/file.gz"]).stream.should == "IO stream"
    end
    
    def source_from(args)
      InputSourceFactory.new(:expected_argument_number => 1, :input_pipe_accepted => true).input_sources_from(args).first
    end
  end
  
  describe Editor do
    it "should write input streams to files" do
      result_aggregator = ""
      editor = Editor.new do |filenames|
        result_aggregator = filenames.inject(result_aggregator) {|agg, f| agg + File.read(f) }
      end
      editor[0] << "file1 "
      editor[1] << "file2 "
      editor[2] << "file3"
      
      editor.edit
      
      result_aggregator.should == "file1 file2 file3"
    end
    
    it "should detect when no changes were made during editing" do
      editor = Editor.new do |filenames| end
      editor[0] << "hello"
      editor.edit
      editor.changed?(0).should be_false
    end
    
    it "should detect when a change was made during editing" do
      now = Time.new
      File.should_receive(:mtime).and_return(now, now+1)
      
      editor = Editor.new do |filenames| end
      editor[0] << "hello"
      editor.edit
      editor.changed?(0).should be_true
    end
  end
  
  describe InputSource do
    it "should read a line from the input stream when prompted to read and should know when it's full or empty" do
      source = InputSource.new("some file", StringIO.new("abc\ndef\n"))
      
      source.should have_records
      source.read.should == "abc\n"
      source.read.should == "def\n"
      source.should_not have_records
    end
  end
end