require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'stringio'

module AsciiDataTools
  module Controller
    class TestEditor
      def consume(filenames)
        @streams = filenames.collect {|f| StringIO.new(File.read(f))}
      end
      
      def [](n)
        @streams[n].string
      end
    end
    
    describe DiffController do
      it "should detect when two streams are the same" do
        pending
        @input_stream = StringIO.new
        @output_stream = StringIO.new
        
        controller = DiffController.new(:input_sources  => [AsciiDataTools::InputSource.new(nil, @input_stream)],
                                        :output_stream  => @output_stream)
        controller.run
        
        @output_stream.string.should == "Identical streams."
      end
      
      it "should detect when one stream has one more record than the other" do
        pending
        @input_stream = StringIO.new("2d1\n< xyz\n")
        @editor = TestEditor.new
        
        controller = DiffController.new(:input_sources  => [AsciiDataTools::InputSource.new(nil, @input_stream)],
                                        :editor         => lambda {|filenames| @editor.consume(filenames) })
        controller.run
        
        @editor[0].should == "xyz\n"
        @editor[1].should be_empty
      end
    end
  end
end