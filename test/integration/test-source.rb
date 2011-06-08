#!/usr/bin/env ruby
require 'test/unit'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test 'source' command handling.
class TestSource < Test::Unit::TestCase

  @@SRC_DIR = File.dirname(__FILE__) unless 
    defined?(@@SRC_DIR)

  require File.join(@@SRC_DIR, 'helper')
  include TestHelper

  def test_basic
    testname='source'
    Dir.chdir(@@SRC_DIR) do 
      script = File.join(%W(.. data #{testname}.cmd))
      assert_equal(true, 
                   run_debugger(testname,
                                "--script #{script} --nx --basename -- " + 
                                '../example/gcd.rb 3 5'))
    end
  end
end
