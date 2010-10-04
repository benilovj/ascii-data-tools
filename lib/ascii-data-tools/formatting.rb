module AsciiDataTools
  module Formatting
    class Formatter
      def initialize
        @record_counter = 0
      end

      def format(record)
        formattable(record.type).format(next_record_counter_and_increment, record.values)
      end
      alias :transform :format
            
      protected
      def next_record_counter_and_increment
        @record_counter += 1
      end
      
      def formattable(record_type)
        record_type.extend(FormatableType) unless record_type.instance_of?(FormatableType)
      end
    end
    
    module FormatableType
      def format(record_number, values)
        template % ([record_number] + escaped(values))
      end
      
      protected
      def template
        @template ||= [header_template, field_templates, footer].flatten.join("\n")
      end
      
      def header_template
        "Record %02d (#{name})"
      end
      
      def field_templates
        make_fields_formatable_if_necessary
        fields.enum_with_index.map do |field, index|
          field.template(:position => index + 1,
                         :longest_field_name => length_of_longest_field_name,
                         :longest_field_length => longest_field_length,
                         :last_field? => (index + 1 == fields.length))
        end
      end
      
      def make_fields_formatable_if_necessary
        fields.each {|field| field.extend(FormatableField) unless field.is_a?(FormatableField) }
      end
      
      def longest_field_length
        if fields.all? {|field| field.respond_to?(:length)}
          fields.max_by {|field| field.length }.length
        else
          0
        end
      end
      
      def escaped(values)
        values.map {|val| val.gsub("\n", "\\n")}
      end
      
      def footer
        "\n"
      end
    end
    
    module UnnumberedFormatableType
      include FormatableType
      
      def format(record_number, values)
        template % escaped(values)
      end
      
      protected
      def header_template
        "Record (#{name})"
      end
    end
    
    module FormatableField
      PAD_CHARACTER = "-"
      MINIMUM_NUMBER_OF_DASHES = 5
      def template(properties)
        "%02d %s : [%s]%s" % [ properties[:position],
                               padded_field_name(name, properties[:longest_field_name]),
                               "%s",
                               padding(properties)
                             ]
      end
      
      protected
      def padded_field_name(field_name, length_of_longest_field_name)
        field_name.ljust(length_of_longest_field_name)
      end
      
      def padding(properties)
        PAD_CHARACTER * number_of_pad_chars(properties)
      end
      
      def number_of_pad_chars(properties)
        return MINIMUM_NUMBER_OF_DASHES unless self.respond_to?(:length)
        return MINIMUM_NUMBER_OF_DASHES + properties[:longest_field_length] - length - (properties[:last_field?] ? 1 : 0)
      end
    end
  end
end