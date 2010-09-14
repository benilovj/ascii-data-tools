require 'optparse'
require 'zlib'
require 'tempfile'

module AsciiDataTools
  class Configuration
    attr_reader :input_sources, :output_stream, :errors, :record_types, :editor, :user_feedback_stream
    
    def initialize(arguments, overrides = {})
      @arguments = arguments
      @overrides = overrides
      @errors = []

      @opts = define_optionparser_configuration
      remainder = parse(arguments)

      @output_stream        = overrides[:output_stream] || STDOUT
      @input_sources        = overrides[:input_sources] || make_input_streams(remainder, overrides)
      @record_types         = overrides[:record_types]  || load_record_types
      @editor               = overrides[:editor]
      @user_feedback_stream = overrides[:user_feedback_stream] || STDOUT
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
    def make_input_streams(remainder, overrides)
      begin
        return InputSourceFactory.new(overrides).input_sources_from(remainder)
      rescue Exception => e
        @errors << e.message
        return nil
      end       
    end
    
    def define_optionparser_configuration
      OptionParser.new do |opts|
        opts.banner = [
          "Usage: #{File.basename($0)} [options] <input source>",
          "An input source can be either a flat file or a gzipped flat file.",
          @overrides[:input_pipe_accepted] ? "For this command, - (STDIN) is also allowed." : nil,
          "\n"].compact.join("\n")
        
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
      rescue SystemExit => e
        exit e.status
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
    def initialize(properties = {})
      @expected_argument_number = properties[:expected_argument_number] || 1
      @input_pipe_accepted = properties[:input_pipe_accepted].nil? ? true : properties[:input_pipe_accepted]
    end
    
    def input_sources_from(input_arguments)
      validate_number_of input_arguments
      return input_arguments.collect {|arg| make_input_source_from(arg)}
    end
    
    protected
    def validate_number_of(input_arguments)
      raise "No input specified." if input_arguments.empty?
      error_message = "#{input_arguments.size} input sources detected: #{input_arguments.inspect}. " +
                      "This command accepts #{@expected_argument_number} input source(s)."
      raise error_message if input_arguments.length != @expected_argument_number
    end
    
    def make_input_source_from(input_argument)
      if input_argument == "-"
        if @input_pipe_accepted
          return InputSource.new(nil, STDIN)
        else
          raise "STDIN not accepted for this command."
        end
      end
      
      path_to_file = input_argument
      raise "File #{path_to_file} does not exist!" unless File.exists?(path_to_file)
      return InputSource.new(path_to_file, Zlib::GzipReader.open(path_to_file)) if path_to_file =~ /[.]gz$/
      return InputSource.new(path_to_file, File.open(path_to_file))
    end
  end
  
  class InputSource < Struct.new(:filename, :stream)
    def read
      stream.readline
    end
    
    def has_records?
      not stream.eof?
    end
  end
  
  class Editor
    def initialize(&edit_command)
      @tempfiles = {}
      @preedit_mtimes = {}
      @postedit_mtimes = {}
      @edit_command = edit_command
    end
    
    def [](n)
      @tempfiles[n] ||= Tempfile.new("ascii_tools")
    end
    
    def edit
      close_all_tempfiles
      save_preedit_mtimes
      edit_files
      save_postedit_mtimes
    end
    
    def changed?(n)
      not @preedit_mtimes[n] == @postedit_mtimes[n]
    end
    
    protected
    def close_all_tempfiles
      @tempfiles.values.each {|f| f.close }
    end
    
    def save_preedit_mtimes
      @tempfiles.each {|n, f| @preedit_mtimes[n] = File.mtime(f.path)}
    end

    def save_postedit_mtimes
      @tempfiles.each {|n, f| @postedit_mtimes[n] = File.mtime(f.path)}
    end
    
    def edit_files
      @edit_command[sorted_filenames]
    end
    
    def sorted_filenames
      @tempfiles.sort.collect {|number, tempfile| tempfile.path}
    end
  end
end