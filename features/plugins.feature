Feature: tools for plugins
  In order to create a plugin that adds custom functionality to the ascii tools  
  As a plugin writer
  I want tools which support readable, compact configurations and configuration debugging

  Scenario: DSL for defining new records and printing the record type summary
    Given the following configuration:
      """
      record_type("XYZ") do
        field "RECORD_TYPE",      :length => 5,  :constrained_to => "REC01"
        field "A_NUMBER",         :length => 16, :constrained_to => /44123/
        field "END_OF_RECORD",    :length => 1
      end

			record_type("ABC") do
			  field "RECORD_TYPE",   :length => 3
			  field "RECORD_SIZE",   :length => 5
			  field "END_OF_RECORD", :length => 1
			end

			record_type("DEF") do
			  field "RECORD_TYPE",   :length => 3
			  field "RECORD_SIZE",   :length => 3
			  field "END_OF_RECORD", :length => 1
			end
      """
    When the record type configuration is printed
    Then it should look like this:
      """
      +-----------+--------------+------------------------------------------+
      | type name | total length | constraints                              |
      +-----------+--------------+------------------------------------------+
      | DEF       | 7            |                                          |
      | ABC       | 9            |                                          |
      | XYZ       | 22           | RECORD_TYPE = REC01, A_NUMBER =~ /44123/ |
      | EXAMPLE02 | 30           | RECORD_TYPE = EXAMPLE02                  |
      | EXAMPLE01 | 49           | RECORD_TYPE = EXAMPLE01                  |
      +-----------+--------------+------------------------------------------+

      """
