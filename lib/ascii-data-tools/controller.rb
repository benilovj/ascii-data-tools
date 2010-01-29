module AsciiDataTools
  module Controller
    class CatController
      def initialize(configuration)
        @configuration = configuration
        @configuration.error_info_with_usage unless @configuration.valid?
      end

      def run
        @type_determiner = RecordType::TypeDeterminer.new(@configuration.record_types)
        @formatter       = Formatting::Formatter.new

        @record_source   = Record::Source.new(@configuration.input_source, @type_determiner)
        @record_sink     = Record::Sink.new(@configuration.output_stream, @formatter)

        Record::Pipeline.new(@record_source, @record_sink).start_flow
      end
      
      def self.from_command_line(command_line_arguments)
        new(Configuration.new(command_line_arguments))
      end
    end
  end
end