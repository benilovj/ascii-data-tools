require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe String do
  it "should split a line which includes single quotes correctly" do
    "abc def 0/' ' 0/'0' XYZ '  '".split_respecting_single_quotes.should == ["abc", "def", "0/' '", "0/'0'", "XYZ", "'  '"]
  end
  
  it "should get rid of superfluous whitespace, tabs and newlines just like a real split" do
    "abc  \t \n   def".split_respecting_single_quotes.should == ["abc", "def"]
  end
end