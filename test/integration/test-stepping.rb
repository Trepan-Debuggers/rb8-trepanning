#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test that step commands
class TestStepping < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  # Test commands in stepping.rb
  def test_basic
    testname='stepping'
    Dir.chdir(@@SRC_DIR) do 
      script = File.join(%W(.. data #{testname}.cmd))
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} --nx --basename -- " +
                                "../example/gcd.rb 3 5"))
    end
  end
end
