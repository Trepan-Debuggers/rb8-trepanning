#!/usr/bin/env ruby
require 'rubygems'; require 'require_relative'
# require_relative '../../lib/trepanning'
require_relative 'helper'

# Test printing (evaluation) of variables
class TestPrintVar < Test::Unit::TestCase
  include TestHelper
  # Test commands in stepping.rb
  def test_basic
    common_setup(__FILE__)
    Dir.chdir(@srcdir) do 
      assert_equal(true, 
                   run_debugger(@testname, @prefix + '../example/gcd.rb 3 5'))
    end
  end
end
