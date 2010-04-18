require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe "the default configuration" do
  it "should add the EXAMPLE01 type to the configuration" do
    require 'ascii-data-tools/discover'
    AsciiDataTools.record_types.find_by_name("EXAMPLE01").should_not be_nil
  end
end