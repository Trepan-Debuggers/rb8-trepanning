#!/usr/bin/env ruby
require 'rubygems'; require 'require_relative'
# require_relative '../../lib/trepanning'
require_relative 'helper'

# Test (mostly) invalid breakpoint commands
class TestBadBreak < Test::Unit::TestCase
  include TestHelper
  def test_basic
    common_setup(__FILE__)
    Dir.chdir(@srcdir) do 
      assert_equal(true, 
                   run_debugger(@testname, @prefix + '../example/gcd.rb 3 5'))
    end
  end
  
  def test_break_loop
    common_setup(__FILE__, 'break_loop_bug')
    Dir.chdir(@srcdir) do 
      assert_equal(true, 
                   run_debugger(@testname, @prefix + 
                                '../example/bp_loop_issue.rb'))
    end
  end

end
