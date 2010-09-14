require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'filter_helper')

require 'ascii-data-tools/configuration'
require 'ascii-data-tools/filter'
require 'stringio'

module AsciiDataTools
  module Filter
    module Diffing
      describe DiffExecutingFilter do
        it "should return the diff if the inputs are not the same" do
          should output("2a3\n> xyz\n").from_upstream([input_source_containing("abc\ndef\n"), input_source_containing("abc\ndef\nxyz\n")])
        end
      
        it "should raise an exception when the streams are the same" do
          filter = DiffExecutingFilter.new
          filter << [input_source_containing("abc\ndef\n"), input_source_containing("abc\ndef\n")]
          lambda { filter.write(StringIO.new) }.should raise_error(StreamsEqualException)
        end
      end
    
      describe DiffParsingFilter do
        it "should sieve the diffs into left and right lines" do
          filter = DiffParsingFilter.new
          filter << input_source_containing("4c4,5\n< abc\n---\n> def\n> ghi\n")
          difference = filter.read
          difference.left_contents.should == ["abc\n"]
          difference.right_contents.should == ["def\n", "ghi\n"]
        end
      
        context "for conflicts" do
          it "should detect a one-line difference" do
            filter = DiffParsingFilter.new
            filter << input_source_containing("4c4\n< abc\n---\n> def\n")
            filter.read.should be_a(Difference)
            filter.should_not have_records
          end
        
          it "should detect a multi-line difference" do
            filter = DiffParsingFilter.new
            filter << input_source_containing("1,2c1,3\n< abc\n< def\n---\n> ghi\n> jkl\n> mno\n")
            filter.read.should be_a(Difference)
            filter.should_not have_records
          end
        end
      
        context "for additions" do
          it "should detect a one-line difference" do
            filter = DiffParsingFilter.new
            filter << input_source_containing("1a2\n> def\n")
            filter.read.should be_a(Difference)
            filter.should_not have_records
          end
      
          it "should detect a multi-line difference" do
            filter = DiffParsingFilter.new
            filter << input_source_containing("1a2,3\n> def\n> xyz\n")
            filter.read.should be_a(Difference)
            filter.should_not have_records
          end
        end
      
        context "for deletions" do
          it "should detect a one-line difference" do
            filter = DiffParsingFilter.new
            filter << input_source_containing("1d2\n< def\n")
            filter.read.should be_a(Difference)
            filter.should_not have_records
          end
      
          it "should detect a multi-line difference" do
            filter = DiffParsingFilter.new
            filter << input_source_containing("1,3d2\n< def\n< xyz\n\< wuv\n")
            filter.read.should be_a(Difference)
            filter.should_not have_records
          end
        end
      end
    end
  end
end