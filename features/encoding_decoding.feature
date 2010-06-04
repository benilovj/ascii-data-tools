Feature: encoding and decoding of records
  In order to understand the contents of ascii-encoded record streams quicker
  As a tester
  I want a tool to be able to handle different types of records
  
  Scenario: decoding fixed-length records
	  Given the following configuration:
		  """
			record_type("ABC") do
			  field "RECORD_TYPE",   :length => 3, :constrained_to => "ABC"
			  field "RECORD_SIZE",   :length => 5
			  field "END_OF_RECORD", :length => 1
			end
		  """
    When I decode an encoded fixed-length record "ABC12345\n" of type "ABC"
    Then I should have a decoded record of type "ABC" and contents:
      | field name    | field value |
      | RECORD_TYPE   | ABC         |
      | RECORD_SIZE   | 12345       |
      | END_OF_RECORD | \n          |