module RecordTypeHelpers
  include AsciiDataTools::RecordType::Builder::TypeBuilder
  
  alias :type :build_type
  alias :make_field :build_field
end
  
