module AsciiDataTools
  module RecordType
    module Field
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
    end
  end
end