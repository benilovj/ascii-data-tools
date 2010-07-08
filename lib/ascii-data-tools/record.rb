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
    
    class TransformingPipeline
      def initialize(&block)
        @transformer_block = block
      end
      
      def stream(record_source, output_stream)
        until record_source.stream.eof?
          original_record = record_source.stream.readline
          transformed_record = @transformer_block[original_record, record_source.filename]
          output_stream << transformed_record
        end
        output_stream.flush
        output_stream.close
      end
    end
    
    class Filter
      def initialize(&block)
        @filter_block = block
      end
      
      def <<(upstream)
        @upstream = upstream
        upstream
      end
      
      def read
        filter(@upstream.read)
      end
      
      def write(output_stream)
        output_stream << read while @upstream.has_records?
      end
      
      def has_records?
        @upstream.has_records?
      end
      
      protected
      def filter(record)
        @filter_block[record]
      end
    end
    
    class BufferingFilter < Filter
      def initialize(&block)
        @first_time = true
        @filter_all_block = block
      end
      
      def read
        if @first_time
          tempfile = buffer_upstream_as_tempfile
          @upstream = InputSource.new(nil, filter_all(tempfile))
          @first_time = false
        end
        @upstream.read
      end
      
      protected
      def filter_all(tempfile)
        @filter_all_block[tempfile]
      end
      
      def buffer_upstream_as_tempfile
        tempfile = Tempfile.new("filter")
        tempfile << @upstream.read while @upstream.has_records?
        tempfile.open
      end
    end
  end
end