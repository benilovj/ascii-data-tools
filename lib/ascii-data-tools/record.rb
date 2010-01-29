require 'set'

module AsciiDataTools
  module Record    
    class Record
      attr_reader :type, :values
      
      def initialize(type, values)
        @type = type
        @values = values
      end
      
      def [](requested_field_name)
        requested_key_value_pair = field_names_and_values.detect {|field_name, value| field_name == requested_field_name }
        raise "Field name '#{requested_field_name}' does not exist!" if requested_key_value_pair.nil?
        requested_key_value_pair.last
      end
      
      def type_name
        @type.name
      end
      
      def to_a
        @type.field_names.zip(@values)
      end
      
      protected
      def field_names_and_values
        @type.field_names.zip(@values)
      end
    end
    
    class Source
      include Enumerable
      
      def initialize(input_source, type_determiner)
        @input_source = input_source
        @type_determiner = type_determiner
      end
      
      def each
        until @input_source.stream.eof?
          encoded_record = @input_source.stream.readline
          type = @type_determiner.determine_type_for(encoded_record, @input_source.filename)
          yield type.decode(encoded_record)
        end
      end
    end
    
    class Sink
      def initialize(output_stream, transformer)
        @output_stream = output_stream
        @transformer = transformer
      end
      
      def receive(record)
        @output_stream << @transformer.transform(record)
      end
      
      def flush_and_close
        @output_stream.flush
        @output_stream.close
      end
    end
  
    class Pipeline
      def initialize(record_source, record_sink)
        @record_source = record_source
        @record_sink = record_sink
      end
      
      def start_flow
        @record_source.each {|record| @record_sink.receive(record)}
        @record_sink.flush_and_close
      end
    end
  end
end