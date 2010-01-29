module AsciiDataTools
  module Formatting
    class Formatter
      def initialize
        @record_counter = 0
        @type_templates = {}
      end

      def format(record)
        type_template_for(record.type).format(next_record_counter_and_increment, record)
      end
      alias :transform :format
            
      protected
      def next_record_counter_and_increment
        @record_counter += 1
      end
      
      def type_template_for(record_type)
        @type_templates[record_type] ||= TypeTemplate.new(record_type)
      end
    end
    
    class TypeTemplate
      MINIMUM_NUMBER_OF_DASHES = 5
      LENGTH_LIMIT_OF_PADDED_LINE = 160
      def initialize(type)
        @type = type
        @field_templates = make_field_templates
      end
      
      def format(record_number, record)
        [[header(record_number)] + dash_padded(field_strings_from(record.values))].join("\n") + "\n\n"
      end
      
      protected
      def make_field_templates
        length_of_longest_field_name = @type.length_of_longest_field_name
        @type.field_names.enum_with_index.map do |field_name, field_index|
          FieldTemplate.new(field_index + 1, field_name, length_of_longest_field_name)
        end
      end
      
      def header(record_number)
        header_template % record_number
      end
      
      def header_template
        @header_template ||= "Record %02d (#{@type.name})"
      end
      
      def field_strings_from(values)
        @field_templates.zip(values).map {|field_template, value| field_template.format(value) }
      end
      
      def dash_padded(field_strings)
        length_of_longest_field_string = field_strings.max_by {|s| s.length}.length
        number_of_dashes = [length_of_longest_field_string + MINIMUM_NUMBER_OF_DASHES, LENGTH_LIMIT_OF_PADDED_LINE].min
        field_strings.collect {|field_string| field_string.ljust(number_of_dashes, "-") }
      end
    end
    
    class FieldTemplate
      def initialize(field_number, field_name, length_of_longest_field_name)
        @field_number = field_number
        @field_name = field_name
        @length_of_longest_field_name = length_of_longest_field_name
      end
      
      def format(value)
        field_template % escape_newline_in(value)
      end
      
      protected
      def field_template
        @field_template ||= "%02d %s" % [@field_number, padded_field_name(@field_name, @length_of_longest_field_name)] + " : [%s]"
      end
      
      def padded_field_name(field_name, length_of_longest_field_name)
        field_name.ljust(length_of_longest_field_name)
      end
      
      def escape_newline_in(field_value)
        field_value.gsub("\n", "\\n")
      end
    end
  end
end