module AsciiDataTools
  module RecordType
    module Decoder
      module RecordDecoder
        def able_to_decode?(encoded_record)
          able_to_decode_content?(encoded_record[:ascii_string]) and meta_fields_valid?(encoded_record)
        end

        def decode(encoded_record)
          Record::Record.new(self, split_into_values(encoded_record[:ascii_string]))
        end
        
        protected
        def able_to_decode_content?(encoded_string)
          raise "Must be implemented in submodule!"
        end
        
        def split_into_values(ascii_string)
          raise "Must be implemented in submodule!"
        end
        
        def meta_fields_valid?(encoded_record)
          encoded_record[:filename].nil? or filename_field.valid_input?(encoded_record[:filename])
        end
        
        def filename_field
          @filename_field ||= fields_by_type[:meta].with_name(:filename)
        end
      end
      
      module RegexpBasedDecoder
        include RecordDecoder

        protected
        def able_to_decode_content?(encoded_string)
          encoded_string =~ regexp_for_matching_type
        end
        
        def split_into_values(ascii_string)
          ascii_string.match(regexp_for_matching_type).to_a[1..-1]
        end
        
        def regexp_for_matching_type
          @regexp ||= Regexp.new(regexp_string, Regexp::MULTILINE)
        end
        
        def regexp_string
          raise "Must be implemented in submodule!"
        end
      end
      
      module FixedLengthRecordDecoder
        include RegexpBasedDecoder
        
        protected        
        def regexp_string
          content_fields.inject("\\A") {|regexp_string, field| field.extend_regexp_string_for_matching(regexp_string) } + "\\z"
        end
      end
      
      module CsvRecordDecoder
        include RegexpBasedDecoder
        
        protected
        def regexp_string
          "\\A" + "(.*?)" + ((field_with_name(:divider).value + "(.*?)") * (content_fields.length - 1))  + "\n\\z"
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