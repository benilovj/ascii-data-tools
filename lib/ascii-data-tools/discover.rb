AsciiDataTools.configure do
  define_record_type("EXAMPLE01") do
    field "RECORD_TYPE",      :length => 9, :constrained_to => "EXAMPLE01"
    field "USAGE",            :length => 3
    field "A_NUMBER",         :length => 16
    field "B_NUMBER",         :length => 16
    field "CHARGEABLE_UNITS", :length => 4
    field "END_OF_RECORD",    :length => 1
  end

  define_record_type("EXAMPLE02") do
    field "RECORD_TYPE",      :length => 9, :constrained_to => "EXAMPLE02"
    field "APN",              :length => 12
    field "SESSION_DURATION", :length => 4
    field "CHARGEABLE_UNITS", :length => 4
    field "END_OF_RECORD",    :length => 1
  end
end