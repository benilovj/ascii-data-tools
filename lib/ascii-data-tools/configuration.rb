require 'optparse'
require 'zlib'

module AsciiDataTools
  class Configuration
    attr_reader :input_source, :output_stream, :errors, :record_types
    
    def initialize(arguments, overrides = {})
      @arguments = arguments
      @errors = []

      @opts = define_optionparser_configuration
      remainder = parse(arguments)

      @output_stream = overrides[:output_stream] || STDOUT
      @input_source = overrides[:input_source] || make_input_stream_from(remainder)
      @record_types = overrides[:record_types] || load_record_types
    end
    
    def valid?
      @errors.empty?
    end
    
    def error_info_with_usage
      @errors.each {|error| puts error}
      puts
      puts @opts
      exit 1
    end
    
    protected
    def make_input_stream_from(remainder)
      begin
        return InputSourceFactory.new(remainder).input_source
      rescue Exception => e
        @errors << e.message
        return nil
      end       
    end
    
    def define_optionparser_configuration
      OptionParser.new do |opts|
        opts.banner = [
          "Usage: ascii-data-cat [options] <input source>",
          "An input source can be a flat file, a gzipped flat file or - (STDIN)",
          "\n"].join("\n")
        
        opts.separator ""
        opts.separator "Other options:"
        
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
    end
    
    def parse(arguments)
      begin
        return @opts.parse(arguments)
      rescue SystemExit
        exit        
      rescue Exception => e
        @errors << e.message
        return []
      end
    end
    
    def load_record_types
      AsciiDataTools.autodiscover
      AsciiDataTools.record_types
    end
    
  end
  
  class InputSourceFactory
    def initialize(input_arguments)
      raise "No input specified." if input_arguments.empty?
      raise "Two input sources detected: #{input_arguments.inspect}. Currently only one input source is supported." if input_arguments.length > 1
      @input_argument = input_arguments.first
    end
    
    def input_source
      return InputSource.new(nil, STDIN) if @input_argument == "-"
      
      path_to_file = @input_argument
      raise "File #{@input_argument} does not exist!" unless File.exists?(path_to_file)
      return InputSource.new(path_to_file, Zlib::GzipReader.open(path_to_file)) if path_to_file =~ /[.]gz$/
      return InputSource.new(path_to_file, File.open(path_to_file))
    end
    
  end
  
  class InputSource < Struct.new(:filename, :stream); end
end