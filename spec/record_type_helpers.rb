module RecordTypeHelpers
  def type(name, &block)
    AsciiDataTools::RecordType::TypeBuilder.new(name, &block).build
  end
  
  def field(name, properties)
    AsciiDataTools::RecordType::FieldBuilder.new.build(name, properties)
  end
end
  
