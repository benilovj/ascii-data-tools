Feature: ascii-data-cat support
  In order to understand the contents of ascii-encoded record streams quicker
  As a tester
  I want to decode and pretty print the streams
  
  Background:
    Given the following configuration:
      """
      record_type("ABC") do
        field "RECORD_TYPE",   :length => 3, :constrained_to => "ABC"
        field "RECORD_SIZE",   :length => 5
        field "END_OF_RECORD", :length => 1
      end
      """
  
  Scenario: two fixed-length records
    When ascii-data-cat is invoked on a record stream containing
      """
      ABC12345
      ABC67890
      
      """
    Then the following is printed out:
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

  Scenario: an unknown record
    When ascii-data-cat is invoked on a record stream containing
      """
      XYZ123456789

      """    
    Then the following is printed out:
      """
      Record 01 (unknown)
      01 UNKNOWN : [XYZ123456789\n]-----


      """
      
  Scenario: record types can be limited to apply only to records contained in particular filenames
    # In this example, the record should not be recognised with type XYZ because the source filename does not match /records[.]XYZ[.]gz/
    Given the following configuration:
      """
      record_type("XYZ", :applies_for_filenames_matching => /records[.]XYZ[.]gz/) do
        field "RECORD_TYPE",   :length => 3
        field "RECORD_SIZE",   :length => 6
        field "END_OF_RECORD", :length => 1
      end
      """
    When ascii-data-cat is invoked on a file "records.ABC.gz" containing
      """
      ABC123456

      """
    Then the following is printed out:
      """
      Record 01 (unknown)
      01 UNKNOWN : [ABC123456\n]-----


      """
      
  Scenario: out-of-the-box example record types defined and configured
    When ascii-data-cat is invoked on a file "records.gz" containing
      """
      EXAMPLE01MO 4912345678      442012345678    0012
      EXAMPLE02internet    2010010112000007220156
      EXAMPLE01SMS4998765432      55555           0099

      """
    Then the following is printed out:
      """
      Record 01 (EXAMPLE01)
      01 RECORD_TYPE      : [EXAMPLE01]------------
      02 USAGE            : [MO ]------------------
      03 A_NUMBER         : [4912345678      ]-----
      04 B_NUMBER         : [442012345678    ]-----
      05 CHARGEABLE_UNITS : [0012]-----------------
      06 END_OF_RECORD    : [\n]-------------------

      Record 02 (EXAMPLE02)
      01 RECORD_TYPE      : [EXAMPLE02]----------
      02 APN              : [internet    ]-------
      03 TIMESTAMP        : [20100101120000]-----
      04 SESSION_DURATION : [0722]---------------
      05 CHARGEABLE_UNITS : [0156]---------------
      06 END_OF_RECORD    : [\n]-----------------

      Record 03 (EXAMPLE01)
      01 RECORD_TYPE      : [EXAMPLE01]------------
      02 USAGE            : [SMS]------------------
      03 A_NUMBER         : [4998765432      ]-----
      04 B_NUMBER         : [55555           ]-----
      05 CHARGEABLE_UNITS : [0099]-----------------
      06 END_OF_RECORD    : [\n]-------------------


      """