module AsciiDataTools
  module Controller
    class CatController
      def initialize(configuration)
        @configuration = configuration
        @configuration.error_info_with_usage unless @configuration.valid?
      end
      
      def self.from_command_line(command_line_arguments)
        new(Configuration.new(command_line_arguments))
      end
      
      def run
        formatter = Formatting::Formatter.new
        type_determiner = RecordType::TypeDeterminer.new(@configuration.record_types)
        
        pipeline = Record::TransformingPipeline.new do |encoded_record, filename|
          type = type_determiner.determine_type_for(encoded_record, filename)
          decoded_record = type.decode(encoded_record)
          formatter.format(decoded_record)
        end
        pipeline.stream(@configuration.input_source, @configuration.output_stream)
      end
    end
    
    class NormalisationController < CatController
      def self.from_command_line(command_line_arguments)
        new(Configuration.new(command_line_arguments))
      end
      
      def run
        type_determiner = RecordType::TypeDeterminer.new(@configuration.record_types)

        pipeline = Record::TransformingPipeline.new do |encoded_record, filename|
          type = type_determiner.determine_type_for(encoded_record, filename)
          type.normalise(encoded_record)
        end
        pipeline.stream(@configuration.input_source, @configuration.output_stream)
      end
    end
  end
end