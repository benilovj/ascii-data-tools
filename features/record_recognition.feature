Feature: intelligent record recognition
  In order to understand the contents of ascii-encoded record streams quicker
  As a tester
  I want a tool to correctly recognise the record type without user intervention
  
  Background:
    Given fixed-length record type "ABC":
      | field name       |  field length | constraint |
      | MD_RECORD_TYPE   |  3            | = ABC      |
      | MD_RECORD_SIZE   |  5            |            |
      | MD_END_OF_RECORD |  1            |            |
    And fixed-length record type "DEF":
      | field name       |  field length | constraint |
      | MD_RECORD_TYPE   |  3            | = DEF      |
      | MD_RECORD_SIZE   |  5            |            |
      | MD_END_OF_RECORD |  1            |            |
    And fixed-length record type "GXX":
      | field name       |  field length | constraint      |
      | MD_RECORD_TYPE   |  3            | one of G01, G02 |
      | MD_RECORD_SIZE   |  5            |                 |
      | MD_END_OF_RECORD |  1            |                 |
    And fixed-length record type "XYZ":
      | field name       |  field length |
      | MD_RECORD_TYPE   |  3            |
      | MD_RECORD_SIZE   |  3            |
      | MD_END_OF_RECORD |  1            |
    And fixed-length record type "TXX_A" which applies for filenames matching "TXX_A":
      | field name       |  field length | constraint |
      | MD_RECORD_TYPE   |  3            | = TXX      |
      | MD_FIELD_A       |  4            |            |
      | MD_END_OF_RECORD |  1            |            |
    And fixed-length record type "TXX_B" which applies for filenames matching "TXX_B":
      | field name       |  field length | constraint |
      | MD_RECORD_TYPE   |  3            | = TXX      |
      | MD_FIELD_B       |  4            |            |
      | MD_END_OF_RECORD |  1            |            |
  
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