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
    
    class CatController < AbstractController
      def run
        formatter = Formatting::Formatter.new
        
        pipeline = Record::TransformingPipeline.new do |encoded_record, filename|
          type = type_determiner.determine_type_for(encoded_record, filename)
          decoded_record = type.decode(encoded_record)
          formatter.format(decoded_record)
        end
        pipeline.stream(@configuration.input_sources.first, @configuration.output_stream)
      end
    end
    
    class NormalisationController < AbstractController
      def run
        pipeline = Record::TransformingPipeline.new do |encoded_record, filename|
          type = type_determiner.determine_type_for(encoded_record, filename)
          type.normalise(encoded_record)
        end
        pipeline.stream(@configuration.input_sources.first, @configuration.output_stream)
      end
    end
    
    class DiffController < AbstractController
      def run
        differ = Editor.new(&@configuration.differ)
        @configuration.input_sources.each_with_index do |input_source, i|
          normed_tempfile = Tempfile.new("norm")
          NormalisationController.new(:input_sources => [input_source],
                                      :output_stream => normed_tempfile,
                                      :record_types  => @configuration.record_types).run
          
          sorted_tempfile = sort(normed_tempfile)
          normed_tempfile.delete
          
          CatController.new(:input_sources => [InputSource.new(input_source.filename, sorted_tempfile)],
                            :output_stream => differ[i],
                            :record_types  => @configuration.record_types).run
          sorted_tempfile.delete
        end
        differ.edit
      end
      
      protected
      def defaults
        {:expected_argument_number => 2,
         :input_pipe_accepted => false,
         :differ => lambda {|filenames| Kernel.system "vimdiff #{filenames.join(' ')}"} }
      end
      
      def sort(tempfile)
        tempfile.close
        
        sorted_tempfile = Tempfile.new("sort")
        sorted_tempfile.close
        
        Kernel.system("sort #{tempfile.path} > #{sorted_tempfile.path}")
        sorted_tempfile.open
        sorted_tempfile
      end
    end
  end
end