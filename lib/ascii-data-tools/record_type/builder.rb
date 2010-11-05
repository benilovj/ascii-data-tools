require 'ascii-data-tools/record_type/field'

module AsciiDataTools
  module RecordType
    module Builder
      module FieldBuilder
        def build_field(name, properties = {})
          field = Field::FixedLengthField.new(name, properties[:length])
          field.should_be_constrained_to(properties[:constrained_to]) unless properties[:constrained_to].nil?
          field.should_be_normalised if properties[:normalised]
          field
        end
      end

      module TypeBuilder
        include FieldBuilder
        def build_type(type_name, properties = {}, &block)
          build_fields(&block)
          type = Type.new(type_name, @fields)
          
          type_family = determine_type_family_from(properties)
          type.extend(type_family)

          type.field_with_name(:filename).should_be_constrained_to(properties[:applies_for_filenames_matching])
          type.field_with_name(:divider).value = properties[:divider]
          type
        end

        def build_fields(&block)
          @fields = Field::Fields.new
          instance_eval(&block) unless block.nil?
          @fields
        end

        protected
        def field(name, properties = {})
          @fields << build_field(name, properties)
        end
        
        def determine_type_family_from(properties)
          case properties[:family]
          when "csv" then CsvType
          when "fixed_length" then FixedLengthType
          when NilClass then FixedLengthType
          end
        end
      end
    end
  end
end