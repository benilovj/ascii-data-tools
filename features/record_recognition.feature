Feature: intelligent record recognition
  In order to understand the contents of ascii-encoded record streams quicker
  As a tester
  I want a tool to correctly recognise the record type without user intervention
  
  Background:
    Given the following configuration:
    """
    record_type("ABC") do
      field "RECORD_TYPE",   :length => 3, :constrained_to => "ABC"
      field "RECORD_SIZE",   :length => 5
      field "END_OF_RECORD", :length => 1
    end

    record_type("DEF") do
      field "RECORD_TYPE",   :length => 3, :constrained_to => "DEF"
      field "RECORD_SIZE",   :length => 5
      field "END_OF_RECORD", :length => 1
    end
    
    record_type("GXX") do
      field "RECORD_TYPE",   :length => 3, :constrained_to => ["G01", "G02"]
      field "RECORD_SIZE",   :length => 5
      field "END_OF_RECORD", :length => 1
    end

    record_type("XYZ") do
      field "RECORD_TYPE",   :length => 3
      field "RECORD_SIZE",   :length => 3
      field "END_OF_RECORD", :length => 1
    end
    
    record_type("TXX_A", :applies_for_filenames_matching => /TXX_A/) do
      field "RECORD_TYPE",   :length => 3, :constrained_to => "TXX"
      field "RECORD_SIZE",   :length => 4
      field "END_OF_RECORD", :length => 1
    end

    record_type("TXX_B", :applies_for_filenames_matching => /TXX_B/) do
      field "RECORD_TYPE",   :length => 3, :constrained_to => "TXX"
      field "RECORD_SIZE",   :length => 4
      field "END_OF_RECORD", :length => 1
    end
    """
  
  Scenario Outline: fixed length record recognition
    When record "<record>" coming from <filename> is analysed
    Then its type should be recognised as "<expected type>"
    
    Examples:
      | record     | filename    | expected type |
      | ABC        | unspecified | unknown       |
      | XYZ123\n   | unspecified | XYZ           |
      | ABC12345\n | unspecified | ABC           |
      | DEF12345\n | unspecified | DEF           |
      | G0112345\n | unspecified | GXX           |
      | G0212345\n | unspecified | GXX           |
      | G0312345\n | unspecified | unknown       |
      | TXX1234\n  | TXX_A.gz    | TXX_A         |
      | TXX1234\n  | TXX_B.gz    | TXX_B         |
      | TXX1234\n  | TXX_Z.gz    | unknown       |