Feature: ascii_cat support
  In order to understand the contents of ascii-encoded record streams quicker
  As a tester
  I want a tool to decode and pretty print the streams
  
  Background:
    Given fixed-length record type "ABC":
      | field name       |  field length |
      | MD_RECORD_TYPE   |  3            |
      | MD_RECORD_SIZE   |  5            |
      | MD_END_OF_RECORD |  1            |
  
  Scenario: two fixed-length records
    Given a record stream containing
      """
      ABC12345
      ABC67890
      
      """
    When ascii_cat is invoked
    Then the following is printed out:
      """
      Record 01 (ABC)
      01 MD_RECORD_TYPE   : [ABC]-------
      02 MD_RECORD_SIZE   : [12345]-----
      03 MD_END_OF_RECORD : [\n]--------
      
      Record 02 (ABC)
      01 MD_RECORD_TYPE   : [ABC]-------
      02 MD_RECORD_SIZE   : [67890]-----
      03 MD_END_OF_RECORD : [\n]--------
      
      
      """

  Scenario: an unknown record
    Given a record stream containing
      """
      XYZ123456789

      """    
    When ascii_cat is invoked
    Then the following is printed out:
      """
      Record 01 (unknown)
      01 UNKNOWN : [XYZ123456789\n]-----


      """
      
  Scenario: record types can be limited to apply only to records contained in particular filenames
    # In this example, the record should not be recognised with type XYZ because the source filename does not match /records[.]XYZ[.]gz/
    Given fixed-length record type "XYZ" which applies for filenames matching "records[.]XYZ[.]gz":
      | field name       |  field length |
      | MD_RECORD_TYPE   |  3            |
      | MD_RECORD_SIZE   |  6            |
      | MD_END_OF_RECORD |  1            |
    And file "records.ABC.gz" containing
      """
      ABC123456

      """    
    When ascii_cat is invoked
    Then the following is printed out:
      """
      Record 01 (unknown)
      01 UNKNOWN : [ABC123456\n]-----


      """