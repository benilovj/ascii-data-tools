lib_path = File.expand_path("#{File.dirname(__FILE__)}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'ascii-data-tools'
require File.join(File.dirname(__FILE__), 'record_type_helpers')