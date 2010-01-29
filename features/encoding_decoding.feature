Feature: encoding and decoding of records
  In order to understand the contents of ascii-encoded record streams quicker
  As a tester
  I want a tool to be able to handle different types of records
  
  Scenario: decoding fixed-length records
    Given fixed-length record type "ABC":
      | field name       |  field length |
      | MD_RECORD_TYPE   |  3            |
      | MD_RECORD_SIZE   |  5            |
      | MD_END_OF_RECORD |  1            |
    When I decode an encoded fixed-length record "ABC12345\n" of type "ABC"
    Then I should have a decoded record of type "ABC" and contents:
      | field name       | field value |
      | MD_RECORD_TYPE   | ABC         |
      | MD_RECORD_SIZE   | 12345       |
      | MD_END_OF_RECORD | \n          |