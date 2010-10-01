require 'ascii-data-tools/record_type/field'

module AsciiDataTools
  module RecordType
    module Builder
      module FieldBuilder
        def build_field(name, properties)
          field = Field::FixedLengthField.new(name, properties[:length])
          field.should_be_constrained_to(properties[:constrained_to]) unless properties[:constrained_to].nil?
          field.should_be_normalised if properties[:normalised]
          field
        end
      end

      module TypeBuilder
        include FieldBuilder
        def build_type(type_name, properties = {}, &block)
          @fields = []
          instance_eval(&block) unless block.nil?
          type = TypeWithFilenameRestrictions.new(type_name, @fields)
          type.filename_should_match(properties[:applies_for_filenames_matching]) unless properties[:applies_for_filenames_matching].nil?
          type
        end

        protected
        def field(name, properties = {})
          @fields << build_field(name, properties)
        end
      end
    end
  end
end