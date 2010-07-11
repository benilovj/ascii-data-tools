require 'tempfile'

module AsciiDataTools
  module Filter
    class Filter
      def initialize(&block)
        @filter_block = block
      end
      
      def <<(upstream_filter)
        @upstream = upstream_filter
        upstream_filter
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
    
    class DiffingFilter < BufferingFilter
      def initialize
        super(&proc {|tempfiles| IO.popen(diff_command_for(tempfiles)) })
      end
            
      protected
      def diff_command_for(tempfiles)
        "diff #{tempfiles.collect {|t| t.path}.join(' ')}"
      end
      
      def upstream
        if @first_time
          tempfiles = @upstream.collect {|stream| buffer_as_tempfile(stream)}
          @upstream = InputSource.new(nil, filter_all(tempfiles))
          @first_time = false
        end
        @upstream
      end
    end
  end
end