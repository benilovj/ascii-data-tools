require 'tempfile'
require 'ascii-data-tools/external_programs'

module AsciiDataTools
  module Filter
    module Diffing
      class DiffFormattingFilter < FormattingFilter
        DIFF_DELIMITER = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
      
        def initialize(type_determiner)
          super(nil, type_determiner)
          def @formatter.make_type_template_for(record_type)
            Formatting::UnnumberedTypeTemplate.new(record_type)
          end
        end
      
        def write(*streams)
          while upstream.has_records?
            difference = upstream.read
            difference.left_contents.each {|rec| streams[0] << filter(rec)}
            difference.right_contents.each {|rec| streams[1] << filter(rec)}
            if upstream.has_records?
              streams[0] << DIFF_DELIMITER
              streams[1] << DIFF_DELIMITER
            end
          end
        end
      end
    
      class DiffExecutingFilter < BufferingFilter
        include ExternalPrograms
        def initialize
          super do |tempfiles|
            stream = diff(tempfiles)
            raise StreamsEqualException.new if stream.eof?
            stream
          end
        end
            
        protected
        def upstream
          if @first_time
            tempfiles = @upstream.collect {|stream| buffer_as_tempfile(stream)}
            @upstream = InputSource.new(nil, filter_all(tempfiles))
            @first_time = false
          end
          @upstream
        end
      end
    
      class StreamsEqualException < Exception
        def initialize
          super("The streams are equal")
        end
      end

      class Difference
        attr_reader :left_contents, :right_contents
      
        def initialize(left_range, right_range)
          @left_range, @right_range = left_range, right_range
          @left_contents, @right_contents = [], []
          @consumed_lines = 0
        end
      
        def complete?
          @consumed_lines == lines_to_consume
        end
      
        def consume(line)
          if line =~ /^[<>]/
            case line[0..0]
            when "<" then @left_contents << line[2..-1]
            when ">" then @right_contents << line[2..-1]
            end
          end
          @consumed_lines += 1
        end
      
        protected
        def left_range_length
          @left_range.to_a.length
        end
      
        def right_range_length
          @right_range.to_a.length
        end      
      end

      class ConflictDifference < Difference
        protected
        def lines_to_consume
          left_range_length + right_range_length + 1
        end
      end

      class AdditionDifference < Difference
        protected
        def lines_to_consume
          right_range_length
        end
      end

      class DeletionDifference < Difference
        protected
        def lines_to_consume
          left_range_length
        end
      end

      class DiffParsingFilter < Filter
        def initialize
          super do |record|
            difference = make_difference_from(record)
            difference.consume(upstream.read) until difference.complete?
            difference
          end
        end
      
        protected
        def make_difference_from(command_record)
          left, command, right = split(command_record)
          case command
          when "c" then ConflictDifference.new(left, right)
          when "a" then AdditionDifference.new(left, right)
          when "d" then DeletionDifference.new(left, right)
          else raise "Cannot parse diff line: #{command_record}"
          end
        end
      
        def split(command_record)
          left_start, _, left_end, command, right_start, _, right_end = command_record.scan(/^(\d([,](\d))?)(c|a|d)(\d([,](\d))?)\Z/).first
          left_range = left_start.to_i..(left_end || left_start).to_i
          right_range = right_start.to_i..(right_end || right_start).to_i
          [left_range, command, right_range]
        end
      end
    end
  end
end