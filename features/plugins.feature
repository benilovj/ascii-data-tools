Feature: tools for plugins
  In order to create a plugin that adds custom functionality to the ascii tools  
  As a plugin writer
  I want tools which support readable, compact configurations and configuration debugging
  
  Background:
    Given fixed-length record type "ABC":
      | field name       |  field length |
      | MD_RECORD_TYPE   |  3            |
      | MD_RECORD_SIZE   |  5            |
      | MD_END_OF_RECORD |  1            |
    And fixed-length record type "DEF":
      | field name       |  field length |
      | MD_RECORD_TYPE   |  3            |
      | MD_RECORD_SIZE   |  3            |
      | MD_END_OF_RECORD |  1            |
  
  Scenario: printing the record type summary
    When the record type configuration is printed
    Then it should look like this:
      """
      +-----------+--------------+-------------------------+
      | type name | total length | constraints             |
      +-----------+--------------+-------------------------+
      | DEF       | 7            |                         |
      | ABC       | 9            |                         |
      | EXAMPLE02 | 30           | RECORD_TYPE = EXAMPLE02 |
      | EXAMPLE01 | 49           | RECORD_TYPE = EXAMPLE01 |
      +-----------+--------------+-------------------------+
      
      """

  Scenario: DSL for defining new records
    Given the following is specified in discover.rb:
      """
      AsciiDataTools.define_record_type("REC01") do
        field "RECORD_TYPE",      :length => 5, :value_is => "REC01"
        field "A_NUMBER",         :length => 16
        field "END_OF_RECORD",    :length => 1
      end
      """
    When the record type configuration is printed
    Then it should look like this:
      """
      +-----------+--------------+-------------------------+
      | type name | total length | constraints             |
      +-----------+--------------+-------------------------+
      | REC01     | 22           | RECORD_TYPE = REC01     |
      | EXAMPLE02 | 30           | RECORD_TYPE = EXAMPLE02 |
      | EXAMPLE01 | 49           | RECORD_TYPE = EXAMPLE01 |
      +-----------+--------------+-------------------------+

      """
