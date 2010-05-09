require 'set'

module AsciiDataTools
  module RecordType    
    class Type
      attr_reader :name
      attr_reader :fields
      
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
      
      def total_length_of_fields
        @total_length ||= @fields.inject(0) {|sum, field| sum + field.length}
      end
      
      def matching?(ascii_string)
        ascii_string =~ regexp_for_matching_type
      end
      
      def length_of_longest_field_name
        @length_of_longest_field_name ||= field_names.max_by {|name| name.length }.length
      end
      
      def constraints_description
        @fields.reject {|field| field.constraint_description.empty? }.map {|field| field.constraint_description}.join(", ")
      end
      
      def decode(ascii_string)
        Record::Record.new(self, split_into_values(ascii_string))
      end
      
      protected
      def split_into_values(ascii_string)
        ascii_string.match(regexp_for_matching_type).to_a[1..-1]
      end
      
      def regexp_string
        @fields.inject("\\A") {|regexp_string, field| field.extend_regexp_string_for_matching(regexp_string) } + "\\z"
      end

      def regexp_for_matching_type
        @regexp ||= Regexp.new(regexp_string, Regexp::MULTILINE)
      end
    end
    
    class UnknownType < Type
      UNKNOWN_RECORD_TYPE_NAME = "unknown"
      
      def initialize
        super(UNKNOWN_RECORD_TYPE_NAME, [Field.new("UNKNOWN")])
      end
      
      def decode(ascii_string)
        Record::Record.new(self, [ascii_string])
      end
    end
    
    class TypeWithFilenameRestrictions < Type
      def initialize(type_name, fields = [], filename_constraint = FilenameConstraint.new)
        super(type_name, fields)
        @filename_constraint = filename_constraint
      end
      
      def matching?(ascii_string, context_filename = nil)
        @filename_constraint.satisfied_by?(context_filename) and super(ascii_string)
      end
      
      def filename_should_match(regexp)
        @filename_constraint = RegexpConstraint.new(regexp)
      end
      
      def constraints_description
        descriptions = [@filename_constraint.to_s, super].reject {|desc| desc.empty?}
        descriptions.join(", ")
      end
    end
    
    class Field
      attr_reader :name
      attr_writer :constraint
      
      def initialize(name, constraint = NoConstraint.new)
        @name = name
        @constraint = constraint
      end
      
      def constraint_description
        unless @constraint.to_s.empty?
          name + " " + @constraint.to_s
        else
          ""
        end
      end

      def should_be_constrained_to(value)
        if value.is_a?(Regexp)
          @constraint = RegexpConstraint.new(value)
        else
          @constraint = OneOfConstraint.new(value)
        end
      end
    end
    
    class FixedLengthField < Field
      attr_reader :length
      
      def initialize(name, length, constraint = nil)
        super(name, constraint || FixedLengthConstraint.new(length))
        @length = length
      end
      
      def extend_regexp_string_for_matching(regexp_string)
        @constraint.extend_regexp_string_for_matching(regexp_string)
      end
    end
    
    class NoConstraint
      def extend_regexp_string_for_matching(regexp_string)
        regexp_string
      end
      
      def to_s; ""; end
    end
    
    class FixedLengthConstraint
      def initialize(length)
        @length = length
      end
      
      def extend_regexp_string_for_matching(regexp_string)
        regexp_string + "(.{#{@length}})"
      end
      
      def to_s; ""; end
    end
    
    class OneOfConstraint
      def initialize(*possible_values)
        @possible_values = possible_values.flatten
      end
      
      def extend_regexp_string_for_matching(regexp_string)
        regexp_string + "(#{@possible_values.join('|')})"
      end
      
      def to_s
        if @possible_values.length == 1
          "= #{@possible_values.first}"
        else
          "one of #{@possible_values.join(', ')}"
        end
      end
    end
    
    class RegexpConstraint
      def initialize(regexp_that_must_match)
        @regexp_that_must_match = regexp_that_must_match
      end

      def extend_regexp_string_for_matching(regexp_string)
        regexp_string + @regexp_that_must_match.source
      end

      def satisfied_by?(string)
        string =~ @regexp_that_must_match
      end

      def to_s
        "=~ #{@regexp_that_must_match.inspect}"
      end
    end
    
    class FilenameConstraint
      def initialize(constraint = nil)
        @filename_constraint = constraint
      end

      def satisfied_by?(string)
        @filename_constraint.nil? or @filename_constraint.satisfied_by?(string)
      end

      def to_s
        unless @filename_constraint.nil?
          "Filename #{@filename_constraint.to_s}"
        else
          ""
        end
      end

      class << self
        def satisfied_by_filenames_matching(regexp)
          new(RegexpConstraint.new(regexp))
        end
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
      
      def initialize(types = [])
        @types = Set.new(types)
      end

      def <<(type)
        @types << type
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
      
      def for_names_matching(regexp, &block)
        select {|type| type.name =~ regexp}.each {|found_type| block[found_type]}
      end
    end

    class TypeBuilder
      def initialize(type_name, &block)
        @name = type_name
        @fields = []

        instance_eval(&block) unless block.nil?
      end

      def build
        TypeWithFilenameRestrictions.new(@name, @fields)
      end

      protected
      def field(name, properties)
        field = FixedLengthField.new(name, properties[:length])
        field.should_be_constrained_to(properties[:constrained_to]) unless properties[:constrained_to].nil?
        @fields << field
      end
    end
  end
end