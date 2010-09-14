Feature: ascii-data-edit support
  In order to create and edit test data efficiently
  As a tester
  I want a tool to edit the streams in a readable form
  
  Background:
    Given the following configuration:
      """
      record_type("ABC") do
        field "RECORD_TYPE",   :length => 3, :constrained_to => "ABC"
        field "RECORD_SIZE",   :length => 5
        field "END_OF_RECORD", :length => 1
      end
      """
  
  Scenario: two fixed-length records opened
    When ascii-data-edit is invoked on a record stream containing
      """
      ABC12345
      ABC67890

      """
    Then the editor shows:
      """
      Record 01 (ABC)
      01 RECORD_TYPE   : [ABC]-------
      02 RECORD_SIZE   : [12345]-----
      03 END_OF_RECORD : [\n]--------

      Record 02 (ABC)
      01 RECORD_TYPE   : [ABC]-------
      02 RECORD_SIZE   : [67890]-----
      03 END_OF_RECORD : [\n]--------


      """
  
  Scenario: two fixed-length records changed
    Given a record stream containing
      """
      ABC12345
      ABC67890
      
      """
    When the output is successfully ascii-edited to the following:
      """
      Record 01 (ABC)
      01 RECORD_TYPE   : [ABC]-------
      02 RECORD_SIZE   : [45678]-----
      03 END_OF_RECORD : [\n]--------
      
      Record 02 (ABC)
      01 RECORD_TYPE   : [ABC]-------
      02 RECORD_SIZE   : [XXXXX]-----
      03 END_OF_RECORD : [\n]--------
      
      
      """
    Then the encoded record stream contains:
      """
      ABC45678
      ABCXXXXX
    
      """
      
  Scenario: files not resaved unless they are modified during editing
    Given a record stream containing
      """
      ABC12345
      ABC67890

      """
    When the output is ascii-edited without alteration
    Then the user receives the following feedback:
      """
      The file is unmodified.
      
      """
  Scenario: editing an unknown record
    When ascii-data-edit is invoked on a record stream containing
      """
      XYZ123456789
  
      """    
    Then the editor shows:
      """
      Record 01 (unknown)
      01 UNKNOWN : [XYZ123456789\n]-----
  
  
      """
