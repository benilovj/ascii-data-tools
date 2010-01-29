module RecordTypeHelpers
  def type(name)
    RecordTypeBuilder.new(name)
  end
  
  def field(name)
    FieldBuilder.new(name)
  end
  
  def fixed_length_field(name, length)
    FixedLengthFieldBuilder.new(name, length)
  end
  
  class RecordTypeBuilder
    def initialize(type_name)
      @type_name = type_name
      @fields = []
    end
    
    def with(*field_builders)
      @fields = field_builders.collect {|field_builder| field_builder.build}      
      self
    end
    
    def applicable_when_filename_matches(regexp)
      @filename_constraint = AsciiDataTools::RecordType::FilenameConstraint.satisfied_by_filenames_matching(regexp)
      self
    end
    
    def build
      if @filename_constraint.nil?
        AsciiDataTools::RecordType::TypeWithFilenameRestrictions.new(@type_name, @fields)
      else
        AsciiDataTools::RecordType::TypeWithFilenameRestrictions.new(@type_name, @fields, @filename_constraint)
      end
    end
  end
  
  class FieldBuilder
    def initialize(field_name)
      @field = AsciiDataTools::RecordType::Field.new(field_name)
    end
    
    def which_equals(value)
      @field.constraint = AsciiDataTools::RecordType::OneOfConstraint.new(value)
      self
    end
    
    def build
      @field
    end
  end

  class FixedLengthFieldBuilder < FieldBuilder
    def initialize(field_name, length)
      @field = AsciiDataTools::RecordType::FixedLengthField.new(field_name, length)
    end
  end
end
  
