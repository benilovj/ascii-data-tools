require 'ascii-data-tools/filter'
require 'lib/ascii-data-tools/external_programs'

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
    
    class CatController < AbstractController
      def run
        input_source = @configuration.input_sources.first

        formatting_filter = Filter::FormattingFilter.new(input_source.filename, type_determiner)
        formatting_filter << input_source
        formatting_filter.write(@configuration.output_stream)
      end
    end
    
    class NormalisationController < AbstractController
      def run
        input_source = @configuration.input_sources.first

        normalising_filter = Filter::NormalisingFilter.new(input_source.filename, type_determiner)
        normalising_filter << input_source
        normalising_filter.write(@configuration.output_stream)
      end
    end
    
    class QDiffController < AbstractController
      include ExternalPrograms
      
      def run
        editor = Editor.new(&@configuration.editor)

        normaliser1    = Filter::NormalisingFilter.new( @configuration.input_sources[0].filename, type_determiner)
        normaliser2    = Filter::NormalisingFilter.new( @configuration.input_sources[1].filename, type_determiner)
        sorter1        = Filter::SortingFilter.new
        sorter2        = Filter::SortingFilter.new
        diff_executer  = Filter::DiffExecutingFilter.new
        diff_parser    = Filter::DiffParsingFilter.new
        diff_formatter = Filter::DiffFormattingFilter.new(type_determiner)
        
        diff_formatter << diff_parser << diff_executer << [sorter1 << normaliser1 << @configuration.input_sources[0],
                                                           sorter2 << normaliser2 << @configuration.input_sources[1]]
        
        begin
          diff_formatter.write(editor[0], editor[1])
          editor.edit
        rescue Filter::StreamsEqualException => e
          @configuration.output_stream.puts "The files are identical."
        end        
      end
      
      protected
      def defaults
        {:expected_argument_number => 2,
         :input_pipe_accepted => false,
         :editor => lambda {|filenames| edit_differences(filenames)} }
      end
    end
  end
end