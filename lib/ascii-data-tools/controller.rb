require 'tempfile'

module AsciiDataTools
  module Controller
    class AbstractController
      def initialize(configuration_or_command_line_arguments)
        case configuration_or_command_line_arguments
        when Hash then
          @configuration = Configuration.new([], defaults.merge(configuration_or_command_line_arguments))
        when Array then
          @configuration = Configuration.new(configuration_or_command_line_arguments, defaults)
        when Configuration then
          @configuration = configuration_or_command_line_arguments
        end
        @configuration.error_info_with_usage unless @configuration.valid?
      end

      def type_determiner
        @type_determiner ||= RecordType::TypeDeterminer.new(@configuration.record_types)
      end
      
      def run
        raise "should be implemented!"
      end
      
      protected
      def defaults
        {:expected_argument_number => 1, :input_pipe_accepted => true}
      end
    end
    
    # class CatController < AbstractController
    #   def run
    #     formatter = Formatting::Formatter.new
    #     
    #     pipeline = Record::TransformingPipeline.new do |encoded_record, filename|
    #       type = type_determiner.determine_type_for(encoded_record, filename)
    #       decoded_record = type.decode(encoded_record)
    #       formatter.format(decoded_record)
    #     end
    #     pipeline.stream(@configuration.input_sources.first, @configuration.output_stream)
    #   end
    # end
    
    class FormattingFilter < Record::Filter
      def initialize(filename, type_determiner)
        @formatter = Formatting::Formatter.new
        @filename = filename
        @type_determiner = type_determiner
      end
      
      def filter(record)
        type = @type_determiner.determine_type_for(record, @filename)
        decoded_record = type.decode(record)
        @formatter.format(decoded_record)
      end
    end
    
    class NormalisingFilter < Record::Filter
      def initialize(filename, type_determiner)
        @filename = filename
        @type_determiner = type_determiner
      end
      
      def filter(record)
        type = @type_determiner.determine_type_for(record, @filename)
        type.normalise(record)
      end
    end
    
    class CatController < AbstractController
      def run
        input_source = @configuration.input_sources.first

        formatting_filter = FormattingFilter.new(input_source.filename, type_determiner)
        formatting_filter << input_source
        formatting_filter.write(@configuration.output_stream)
      end
    end
    
    class NormalisationController < AbstractController
      def run
        input_source = @configuration.input_sources.first

        normalising_filter = NormalisingFilter.new(input_source.filename, type_determiner)
        normalising_filter << input_source
        normalising_filter.write(@configuration.output_stream)
      end
    end
    
    class DiffController < AbstractController
      def run
        @configuration.output_stream << "Identical streams." if input_stream.eof?
      end
      
      protected
      def input_stream
        @configuration.input_sources.first.stream
      end
      
      def defaults
        {:expected_argument_number => 2,
         :input_pipe_accepted => false}
      end
    end
    
    class SortingFilter < Record::BufferingFilter
      def filter_all(tempfile)
        tempfile.close
        
        sorted_tempfile = Tempfile.new("sort")
        sorted_tempfile.close
        
        Kernel.system("sort #{tempfile.path} > #{sorted_tempfile.path}")
        sorted_tempfile.open
      end
    end
    
    class QDiffController < AbstractController
      def run
        editor = Editor.new(&@configuration.editor)
        @configuration.input_sources.each_with_index do |input_source, i|
          normalising_filter = NormalisingFilter.new(input_source.filename, type_determiner)
          sorting_filter     = SortingFilter.new
          formatting_filter  = FormattingFilter.new(input_source.filename, type_determiner)
          
          formatting_filter << sorting_filter << normalising_filter << input_source

          formatting_filter.write(editor[i])
        end
        editor.edit
      end
      
      protected
      def defaults
        {:expected_argument_number => 2,
         :input_pipe_accepted => false,
         :editor => lambda {|filenames| Kernel.system "vimdiff #{filenames.join(' ')}"} }
      end
    end
  end
end