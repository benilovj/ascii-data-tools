Feature: normalisation
  In order to see differences between two streams of record streams with variable parameters like timestamps
  As a tester
  I want a tool to normalise which outputs normalised raw records
  
  Scenario: two fixed-length records
    Given the following configuration:
      """
      record_type("ABC") do
        field "RECORD_TYPE",   :length => 3, :constrained_to => "ABC"
        field "RECORD_SIZE",   :length => 5
        field "TIMESTAMP",     :length => 14, :normalised => true
        field "END_OF_RECORD", :length => 1
      end
      """
    When ascii-data-norm is invoked on a record stream containing
      """
      ABC1234520100101120000
      ABC6789020100415180005
      
      """
    Then the following is printed out:
      """
      ABC12345XXXXXXXXXXXXXX
      ABC67890XXXXXXXXXXXXXX
    
      """
