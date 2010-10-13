require 'set'

module AsciiDataTools
  module Record    
    class Record
      attr_reader :type
      
      def initialize(type, content_values)
        @type = type
        @values_by_type = {:content => content_values}
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
        @type.field_names.zip(values)
      end
      
      def values
        @values_by_type[:content]
      end
      
      def encode
        @type.encode(values)
      end
      
      def to_s
        contents = field_names_and_values.map {|field_name, value| "#{field_name} => #{value.inspect}"}.join(", ")
        "#{type_name}: #{contents}"
      end
      
      def ==(other)
        self.type == other.type and self.values == other.values
      end
      
      protected
      def field_names_and_values
        @type.field_names.zip(values)
      end
    end
  end
end