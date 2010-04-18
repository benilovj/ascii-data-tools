include AsciiDataTools::RecordType

AsciiDataTools.register_record_type(TypeWithFilenameRestrictions.new("EXAMPLE01", [
  FixedLengthField.new("RECORD_TYPE",      9, OneOfConstraint.new("EXAMPLE01")),
  FixedLengthField.new("USAGE",            3),
  FixedLengthField.new("A_NUMBER",         16),
  FixedLengthField.new("B_NUMBER",         16),
  FixedLengthField.new("CHARGEABLE_UNITS", 4),
  FixedLengthField.new("END_OF_RECORD",    1)
]))

AsciiDataTools.register_record_type(TypeWithFilenameRestrictions.new("EXAMPLE02", [
  FixedLengthField.new("RECORD_TYPE",      9, OneOfConstraint.new("EXAMPLE02")),
  FixedLengthField.new("APN",              12),
  FixedLengthField.new("SESSION_DURATION", 4),
  FixedLengthField.new("CHARGEABLE_UNITS", 4),
  FixedLengthField.new("END_OF_RECORD",    1)
]))