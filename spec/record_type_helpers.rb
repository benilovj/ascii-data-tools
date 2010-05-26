module RecordTypeHelpers
  include AsciiDataTools::RecordType::TypeBuilder
  include AsciiDataTools::RecordType::FieldBuilder
  
  alias :type :build_type
  alias :make_field :build_field
end
  
