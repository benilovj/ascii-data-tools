Feature: encoding and decoding of records
  In order to understand the contents of ascii-encoded record streams quicker
  As a tester
  I want a tool to be able to handle different types of records
  
  Scenario: decoding fixed-length records
    Given the following configuration:
      """
      record_type("ABC") do
        field "RECORD_TYPE",   :length => 3
        field "RECORD_SIZE",   :length => 5
        field "END_OF_RECORD", :length => 1
      end
      """
    When I decode an encoded record "ABC12345\n" of type "ABC"
    Then I should have a decoded record of type "ABC" and contents:
      | field name    | field value |
      | RECORD_TYPE   | ABC         |
      | RECORD_SIZE   | 12345       |
      | END_OF_RECORD | \n          |

  Scenario: encoding fixed-length records
    Given the following configuration:
      """
      record_type("ABC") do
        field "RECORD_TYPE",   :length => 3
        field "RECORD_SIZE",   :length => 5
        field "END_OF_RECORD", :length => 1
      end
      """
    When I encode a record of type "ABC" and contents:
      | field name    | field value |
      | RECORD_TYPE   | ABC         |
      | RECORD_SIZE   | 12345       |
      | END_OF_RECORD | \n          |
    Then I should have a encoded record "ABC12345\n"
      
  Scenario: decoding csv records
    Given the following configuration:
      """
      record_type("ABC", :family => "csv", :divider => ",") do
        field "RECORD_TYPE"
        field "RECORD_SIZE"
        field "UNITS"
      end
      """
    When I decode an encoded record "ABC,12345,123\n" of type "ABC"
    Then I should have a decoded record of type "ABC" and contents:
      | field name    | field value |
      | RECORD_TYPE   | ABC         |
      | RECORD_SIZE   | 12345       |
      | UNITS         | 123         |

  Scenario: encoding csv records
    Given the following configuration:
      """
      record_type("ABC", :family => "csv", :divider => ",") do
        field "RECORD_TYPE"
        field "RECORD_SIZE"
        field "UNITS"
      end
      """
    When I encode a record of type "ABC" and contents:
      | field name    | field value |
      | RECORD_TYPE   | ABC         |
      | RECORD_SIZE   | 12345       |
      | UNITS         | XX          |
    Then I should have a encoded record "ABC,12345,XX\n"