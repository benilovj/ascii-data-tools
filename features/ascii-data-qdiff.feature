Feature: ascii-data-qdiff support
  In order to see the difference between the contents of ascii-encoded record streams
  As a tester
  I want a tool to decode, normalise, sort, pretty print the streams and show them in a diffing editor
  
  Scenario: comparing identical files
    When ascii-data-qdiff is invoked on files containing:
      """
      EXAMPLE01MO 1112345678      442012345678    0012\n  ||  EXAMPLE01MO 1112345678      442012345678    0012\n
      """
    Then the following is printed out:
      """
      The files are identical.
      
      """

  Scenario: normal execution
    When ascii-data-qdiff is invoked on files containing:
      """
      EXAMPLE01MO 1112345678      442012345678    0012\n  ||  EXAMPLE01MO 9954321098      442012345678    0012\n
      EXAMPLE02internet    2010010112000007220156\n       ||  EXAMPLE02internet    2010010112000007220156\n
      EXAMPLE01SMS4998765432      55555           0099\n  ||  --------------------------------------------------
      """
    Then the diffed result should be:
      """
      Record (EXAMPLE01)                             ||  Record (EXAMPLE01)
      01 RECORD_TYPE      : [EXAMPLE01]------------  ||  01 RECORD_TYPE      : [EXAMPLE01]------------
      02 USAGE            : [MO ]------------------  ||  02 USAGE            : [MO ]------------------
      03 A_NUMBER         : [1112345678      ]-----  ||  03 A_NUMBER         : [9954321098      ]-----
      04 B_NUMBER         : [442012345678    ]-----  ||  04 B_NUMBER         : [442012345678    ]-----
      05 CHARGEABLE_UNITS : [0012]-----------------  ||  05 CHARGEABLE_UNITS : [0012]-----------------
      06 END_OF_RECORD    : [\n]-------------------  ||  06 END_OF_RECORD    : [\n]-------------------
                                                     ||  
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~||  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                                     ||  
      Record (EXAMPLE01)                             ||  -----------------------------------------------
      01 RECORD_TYPE      : [EXAMPLE01]------------  ||  -----------------------------------------------
      02 USAGE            : [SMS]------------------  ||  -----------------------------------------------
      03 A_NUMBER         : [4998765432      ]-----  ||  -----------------------------------------------
      04 B_NUMBER         : [55555           ]-----  ||  -----------------------------------------------
      05 CHARGEABLE_UNITS : [0099]-----------------  ||  -----------------------------------------------
      06 END_OF_RECORD    : [\n]-------------------  ||  -----------------------------------------------
                                                     ||  -----------------------------------------------
      """
