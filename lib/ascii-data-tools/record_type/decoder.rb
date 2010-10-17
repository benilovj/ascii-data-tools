module AsciiDataTools
  module RecordType
    module Decoder
      module RecordContentDecoder
        protected
        def able_to_decode_content?(encoded_string)
          encoded_string =~ regexp_for_matching_type
        end
        
        def split_into_values(ascii_string)
          ascii_string.match(regexp_for_matching_type).to_a[1..-1]
        end
      
        def regexp_string
          content_fields.inject("\\A") {|regexp_string, field| field.extend_regexp_string_for_matching(regexp_string) } + "\\z"
        end

        def regexp_for_matching_type
          @regexp ||= Regexp.new(regexp_string, Regexp::MULTILINE)
        end
      end
      
      module RecordDecoder
        include RecordContentDecoder
        
        def able_to_decode?(encoded_record)
          able_to_decode_content?(encoded_record[:ascii_string]) and meta_fields_valid?(encoded_record)
        end

        def decode(encoded_record)
          Record::Record.new(self, split_into_values(encoded_record[:ascii_string]))
        end
        
        protected
        def meta_fields_valid?(encoded_record)
          # raise field_with_name(:filename).inspect
          encoded_record[:filename].nil? or field_with_name(:filename).valid_input?(encoded_record[:filename])
        end
      end
    
      module UnknownRecordDecoder
        def decode(encoded_record)
          Record::Record.new(self, [encoded_record[:ascii_string]])
        end
      end
    end
  end
end