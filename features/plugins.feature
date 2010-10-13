Feature: tools for plugins
  In order to create a plugin that adds custom functionality to the ascii tools  
  As a plugin writer
  I want tools which support readable, compact configurations and configuration debugging

  Scenario: defining new record types and printing the record type summary
    Given the following configuration:
      """
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
      +-----------+--------------+-------------------------+-------------------+
      | type name | total length | constraints             | normalised fields |
      +-----------+--------------+-------------------------+-------------------+
      | DEF       | 7            |                         |                   |
      | ABC       | 9            |                         |                   |
      | EXAMPLE02 | 44           | RECORD_TYPE = EXAMPLE02 | TIMESTAMP         |
      | EXAMPLE01 | 49           | RECORD_TYPE = EXAMPLE01 |                   |
      +-----------+--------------+-------------------------+-------------------+

      """
      
  Scenario: defining constraints on record types
    Given the following configuration:
      """
      record_type("XYZ") do
        field "RECORD_TYPE",      :length => 5,  :constrained_to => "REC01"
        field "A_NUMBER",         :length => 16, :constrained_to => /44123/
        field "END_OF_RECORD",    :length => 1
      end
      """
    When the record type configuration is printed
    Then it should look like this:
      """
      +-----------+--------------+------------------------------------------+-------------------+
      | type name | total length | constraints                              | normalised fields |
      +-----------+--------------+------------------------------------------+-------------------+
      | XYZ       | 22           | RECORD_TYPE = REC01, A_NUMBER =~ /44123/ |                   |
      | EXAMPLE02 | 44           | RECORD_TYPE = EXAMPLE02                  | TIMESTAMP         |
      | EXAMPLE01 | 49           | RECORD_TYPE = EXAMPLE01                  |                   |
      +-----------+--------------+------------------------------------------+-------------------+

      """

  Scenario: normalising and grepping record types
    Given the following configuration:
      """
      for_names_matching(/EXAMPLE\d/) {|type| type.fields_with {|field| field.name =~ /RECORD_/}.should_be_normalised }
      type("EXAMPLE01").field_with_index(2).should_be_normalised
      """
    When the record type configuration is printed
    Then it should look like this:
      """
      +-----------+--------------+-------------------------+------------------------+
      | type name | total length | constraints             | normalised fields      |
      +-----------+--------------+-------------------------+------------------------+
      | EXAMPLE02 | 44           | RECORD_TYPE = EXAMPLE02 | RECORD_TYPE, TIMESTAMP |
      | EXAMPLE01 | 49           | RECORD_TYPE = EXAMPLE01 | RECORD_TYPE, USAGE     |
      +-----------+--------------+-------------------------+------------------------+

      """
