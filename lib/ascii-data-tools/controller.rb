require 'ascii-data-tools/filter'

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
    
    class QDiffController < AbstractController
      def run
        editor = Editor.new(&@configuration.editor)
        @configuration.input_sources.each_with_index do |input_source, i|
          normalising_filter = Filter::NormalisingFilter.new(input_source.filename, type_determiner)
          sorting_filter     = Filter::SortingFilter.new
          formatting_filter  = Filter::FormattingFilter.new(input_source.filename, type_determiner)
          
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