require 'set'
require 'ascii-data-tools/record_type/field'
require 'ascii-data-tools/record_type/builder'
require 'ascii-data-tools/record_type/normaliser'
require 'ascii-data-tools/record_type/decoder'
require 'ascii-data-tools/record_type/encoder'

module AsciiDataTools
  module RecordType
    module FixedLengthType
      include Decoder::RecordDecoder
      include Encoder::RecordEncoder
      include Normaliser::Normaliser
      
      def total_length_of_fields
        @total_length ||= @fields.inject(0) {|sum, field| sum + field.length}
      end
    end
    
    class Type
      include FixedLengthType
      attr_reader :name
      
      def initialize(name, fields = [])
        @name = name
        @fields = fields
      end
      
      def [](field_name)
        @fields.detect {|field| field.name == field_name}
      end
      
      def <<(field)
        @fields << field
      end
      
      def field_names
        @fields.collect {|f| f.name}
      end
      
      def number_of_content_fields
        @fields.size
      end
      
      def length_of_longest_field_name
        @length_of_longest_field_name ||= field_names.max_by {|name| name.length }.length
      end
      
      def constraints_description
        @fields.reject {|field| field.constraint_description.empty? }.map {|field| field.constraint_description}.join(", ")
      end
      
      protected
      attr_reader :fields
    end
    
    class UnknownType < Type
      UNKNOWN_RECORD_TYPE_NAME = "unknown"
      
      def initialize
        super(UNKNOWN_RECORD_TYPE_NAME, [Field::Field.new("UNKNOWN")])
      end
      
      def decode(ascii_string)
        Record::Record.new(self, [ascii_string])
      end
    end
    
    class TypeWithFilenameRestrictions < Type
      def initialize(type_name, fields = [], filename_constraint = Field::FilenameConstraint.new)
        super(type_name, fields)
        @filename_constraint = filename_constraint
      end
      
      def matching?(ascii_string, context_filename = nil)
        @filename_constraint.satisfied_by?(context_filename) and super(ascii_string)
      end
      
      def filename_should_match(regexp)
        @filename_constraint = Field::FilenameConstraint.satisfied_by_filenames_matching(regexp)
        self
      end
      
      def constraints_description
        descriptions = [@filename_constraint.to_s, super].reject {|desc| desc.empty?}
        descriptions.join(", ")
      end
    end

    class TypeDeterminer
      def initialize(type_repo = RecordTypeRepository.new)
        @all_types = type_repo
        @previously_matched_types = RecordTypeRepository.new
      end

      def determine_type_for(encoded_record_string, context_filename = nil)
        matching_type = 
          @previously_matched_types.find_for_record(encoded_record_string, context_filename) || 
          @all_types.find_for_record(encoded_record_string, context_filename)
        if matching_type.nil?
          return UnknownType.new
        else
          @previously_matched_types << matching_type
          return matching_type
        end
      end
    end
    
    class RecordTypeRepository
      include Enumerable
      include Builder::TypeBuilder
      
      def initialize(types = [])
        @types = Set.new(types)
      end

      def <<(type)
        @types << type
      end

      def clear
        @types.clear
      end

      def find_by_name(name)
        detect {|type| type.name == name}
      end

      alias :type :find_by_name

      def each(&block)
        @types.each(&block)
      end

      def find_for_record(encoded_record_string, context_filename)
        @types.detect {|type| type.matching?(encoded_record_string, context_filename) }
      end
      
      def for_names_matching(matcher, &block)
        if matcher.is_a?(Regexp)
          select {|type| type.name =~ matcher}.each {|found_type| block[found_type]}
        elsif matcher.is_a?(Proc)
          select {|type| matcher[type.name]}.each {|found_type| block[found_type]}
        end
      end
      
      def record_type(name, props = {}, &definition)
        self << build_type(name, props, &definition)
      end
    end
  end
end