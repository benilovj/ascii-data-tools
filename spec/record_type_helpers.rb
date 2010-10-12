module RecordTypeHelpers
  include AsciiDataTools::RecordType::Builder::TypeBuilder
  
  alias :type :build_type
  alias :fields :build_fields
  alias :make_field :build_field
end
  
