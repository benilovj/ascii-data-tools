module AsciiDataTools
  module RecordType
    module Decoder
      module RecordDecoder
        def able_to_decode?(ascii_string)
          ascii_string =~ regexp_for_matching_type
        end

        def decode(ascii_string)
          Record::Record.new(self, split_into_values(ascii_string))
        end
      
        alias :matching? :able_to_decode?

        protected
        def split_into_values(ascii_string)
          ascii_string.match(regexp_for_matching_type).to_a[1..-1]
        end
      
        def regexp_string
          fields.inject("\\A") {|regexp_string, field| field.extend_regexp_string_for_matching(regexp_string) } + "\\z"
        end

        def regexp_for_matching_type
          @regexp ||= Regexp.new(regexp_string, Regexp::MULTILINE)
        end
      end
    end
  end
end