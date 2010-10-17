  require 'set'
require 'forwardable'
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
        @total_length ||= fields.inject(0) {|sum, field| sum + field.length}
      end
    end
    
    class Type
      include FixedLengthType
      extend Forwardable
      attr_reader :name
      
      def_delegator  :fields, :names, :field_names
      def_delegator  :fields, :with_index, :field_with_index
      
      def initialize(name, content_fields = Field::Fields.new)
        @name = name
        @fields_by_type = {:content => content_fields, :meta => make_meta_fields}
      end
      
      def field_with_name(name)
        all_fields.with_name(name)
      end
      
      def method_missing(method_name, *args, &block)
        content_fields.send(method_name, *args, &block)
      end
      
      def filename_should_match(value)
        field_with_name(:filename).should_be_constrained_to(value)
      end
      
      protected
      def content_fields
        @fields_by_type[:content]
      end

      alias :fields :content_fields
      
      def make_meta_fields
        Field::Fields.new([Field::Field.new(:filename)])
      end
      
      def all_fields
        Field::Fields.new(@fields_by_type[:content] + @fields_by_type[:meta])
      end
    end
    
    class UnknownType < Type
      include Decoder::UnknownRecordDecoder
      UNKNOWN_RECORD_TYPE_NAME = "unknown"
      
      def initialize
        super(UNKNOWN_RECORD_TYPE_NAME, Field::Fields.new([Field::Field.new("UNKNOWN")]))
      end      
    end

    class TypeDeterminer
      def initialize(type_repo = RecordTypeRepository.new)
        @all_types = type_repo
        @previously_matched_types = RecordTypeRepository.new
      end

      def determine_type_for(encoded_record)
        matching_type = 
          @previously_matched_types.identify_type_for(encoded_record) || 
          @all_types.identify_type_for(encoded_record)
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

      def identify_type_for(encoded_record)
        @types.detect {|type| type.able_to_decode?(encoded_record) }
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