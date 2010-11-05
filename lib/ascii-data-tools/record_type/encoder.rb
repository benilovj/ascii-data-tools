module AsciiDataTools
  module RecordType
    module Encoder
      module FixedLengthRecordEncoder
        def encode(values)
          values.join
        end
      end
      
      module CsvRecordEncoder
        def encode(values)
          values.join(field_with_name(:divider).value) + "\n"
        end
      end
    end
  end
end