module AsciiDataTools
  module RecordType
    module Field
      module GreppableFields
        def with_name(field_name)
          self.detect {|field| field.name == field_name}
        end
        
        def fields_with(&block)
          Fields.new(self.select(&block))
        end
        
        def with_index(index)
          self[index-1]
        end
      end
      
      class Fields < Array
        include GreppableFields
        def names
          self.collect {|f| f.name}
        end
        
        def number_of_content_fields
          self.size
        end
        
        def length_of_longest_field_name
          @length_of_longest_field_name ||= names.max_by {|name| name.length }.length
        end
        
        def constraints_description
          self.reject {|field| field.constraint_description.empty? }.map {|field| field.constraint_description}.join(", ")
        end
        
        def should_be_normalised
          self.each {|field| field.should_be_normalised}
        end
        
        def names_of_normalised_fields
          self.select {|field| field.normalised?}.map {|field| field.name}.join(", ")
        end
      end
      
      class Field
        attr_reader :name
        attr_writer :constraint
      
        def initialize(name, constraint = NoConstraint.new)
          @name = name
          @constraint = constraint
          @normalised = false
        end
      
        def normalised?
          @normalised
        end
      
        def should_be_normalised
          @normalised = true
        end
      
        def constraint_description
          unless @constraint.to_s.empty?
            name.to_s + " " + @constraint.to_s
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
        
        def valid_input?(value)
          @constraint.satisfied_by?(value)
        end
      end
      
      class ConstantField < Field
        attr_accessor :value
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
      
        def satisfied_by?(string)
          true
        end
      
        def to_s; ""; end
      end
    
      class Constraint
        def satisfied_by?(string)
          string =~ Regexp.new(extend_regexp_string_for_matching(""))
        end
      end
    
      class FixedLengthConstraint < Constraint
        def initialize(length)
          @length = length
        end
      
        def extend_regexp_string_for_matching(regexp_string)
          regexp_string + "(.{#{@length}})"
        end
      
        def to_s; ""; end
      end
    
      class OneOfConstraint < Constraint
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
    
      class RegexpConstraint < Constraint
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
    end
  end
end