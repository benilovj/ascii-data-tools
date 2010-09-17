module AsciiDataTools
  module RecordType
    module Normaliser
      module Normaliser
        def normalise(encoded_record)
          @regexps_to_normalise_fields ||= make_regexps_to_normalise_fields
          fields_to_normalise.inject(encoded_record) do |normalised_string, field|
            normalised_string.gsub(@regexps_to_normalise_fields[field], '\1' + 'X' * field.length + '\3' )
          end
        end

        protected
        def make_regexps_to_normalise_fields
          fields_to_normalise.inject({}) {|map, field| map[field] = make_normalising_regexp_for(field); map }
        end

        def fields_to_normalise
          @fields_to_normalise ||= fields.select {|f| f.normalised?}
        end

        def make_normalising_regexp_for(field)
          index_of_normalised_field = fields.index(field)
          preceeding_fields = fields[0...index_of_normalised_field]
          proceeding_fields = fields[index_of_normalised_field+1..-1]

          regexp_for_preceeding_fields = preceeding_fields.collect {|f| length_match_for(f) }.join
          regexp_for_proceeding_fields = proceeding_fields.collect {|f| length_match_for(f) }.join

          Regexp.new("^(%s)(%s)(%s)$" % [regexp_for_preceeding_fields, length_match_for(field), regexp_for_proceeding_fields], Regexp::MULTILINE)
        end

        def length_match_for(field)
          ".{#{field.length}}"
        end
      end
    end
  end
end