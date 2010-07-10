require 'tempfile'

module AsciiDataTools
  module Filter
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
    
    class FormattingFilter < Filter
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
    
    class NormalisingFilter < Filter
      def initialize(filename, type_determiner)
        @filename = filename
        @type_determiner = type_determiner
      end
      
      def filter(record)
        type = @type_determiner.determine_type_for(record, @filename)
        type.normalise(record)
      end
    end
    
    class SortingFilter < BufferingFilter
      def filter_all(tempfile)
        tempfile.close
        
        sorted_tempfile = Tempfile.new("sort")
        sorted_tempfile.close
        
        Kernel.system("sort #{tempfile.path} > #{sorted_tempfile.path}")
        sorted_tempfile.open
      end
    end
  end
end