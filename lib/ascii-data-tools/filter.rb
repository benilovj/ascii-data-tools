require 'tempfile'
require 'ascii-data-tools/external_programs'

module AsciiDataTools
  module Filter
    class Filter
      def initialize(&block)
        @filter_block = block
      end
      
      def <<(upstream_filter)
        @upstream = upstream_filter
        self
      end
      
      def read
        filter(upstream.read)
      end
      
      def write(output_stream)
        output_stream << read while has_records?
      end
      
      def has_records?
        upstream.has_records?
      end
      
      protected
      def filter(record)
        @filter_block[record]
      end
      
      def upstream
        @upstream
      end
    end
    
    class BufferingFilter < Filter
      def initialize(&block)
        @first_time = true
        @filter_all_block = block
      end
      
      protected
      def filter_all(tempfile)
        @filter_all_block[tempfile]
      end
      
      def filter(record)
        record
      end
      
      def upstream
        if @first_time
          tempfile = buffer_as_tempfile(@upstream)
          @upstream = InputSource.new(nil, filter_all(tempfile))
          @first_time = false
        end
        @upstream
      end
      
      def buffer_as_tempfile(stream)
        tempfile = Tempfile.new("filter")
        tempfile << stream.read while stream.has_records?
        tempfile.open
      end
    end
    
    class FormattingFilter < Filter
      def initialize(filename, type_determiner)
        @formatter = Formatting::Formatter.new
        @filename = filename
        @type_determiner = type_determiner
      end
      
      def filter(record)
        type = @type_determiner.determine_type_for(:ascii_string => record, :filename => @filename)
        decoded_record = type.decode(record)
        @formatter.format(decoded_record)
      end
    end
    
    class NormalisingFilter < Filter
      def initialize(filename, type_determiner)
        @filename = filename
        @type_determiner = type_determiner
      end
      
      def filter(record)
        type = @type_determiner.determine_type_for(:ascii_string => record, :filename => @filename)
        type.normalise(record)
      end
    end
    
    class SortingFilter < BufferingFilter
      include ExternalPrograms
      def filter_all(tempfile)
        tempfile.close
        
        sorted_tempfile = Tempfile.new("sort")
        sorted_tempfile.close
        
        sort(tempfile, sorted_tempfile)
        sorted_tempfile.open
      end
    end
    
    class ParsingFilter < Filter
      def initialize(record_types)
        @record_types = record_types
      end
      
      def filter(record)
        header_line = record
        record_type = identify_record_type_from(header_line)
        values = parse_values_from_subsequent_lines(record_type)
        
        consume_empty_line_between_records
        
        AsciiDataTools::Record::Record.new(record_type, values)
      end
      
      protected
      def identify_record_type_from(header_line)
        match = header_line.match(/Record \d+ \((.*?)\)/)
        raise "Cannot find record type in line #{header_line}!" unless match
        expected_record_type_name = match[1]
        @record_types.find_by_name(expected_record_type_name)
      end
      
      def parse_values_from_subsequent_lines(record_type)
        values = []
        record_type.number_of_content_fields.times { values << parse_value_from(upstream.read) }
        values
      end
      
      def parse_value_from(line)
        value = line.match(/.*?\[(.*?)\]/)[1]
        value.gsub("\\n", "\n")
      end
      
      def consume_empty_line_between_records
        upstream.read
      end
    end
  end
end