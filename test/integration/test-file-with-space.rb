#!/usr/bin/env ruby
require 'rubygems'; require 'require_relative'
# require_relative '../../lib/trepanning'
require_relative 'helper'

# Test Running a program wiht an embedded space
class TestFileWithSpace < Test::Unit::TestCase
  include TestHelper

  def test_basic
    testname='file-with-space'
    common_setup(__FILE__)
    Dir.chdir(@srcdir) do 
      script = File.join(%W(.. data #{testname}.cmd))
#       filter = Proc.new{|got_lines, correct_lines|
#         [got_lines[0], correct_lines[0]].each do |s|
#           s.sub!(/tdebug.rb:\d+/, 'rdebug:999')
#         end
#       }
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} --nx --basename -- " +
                                "'../example/file with space.rb'"))
    end
  end
end
