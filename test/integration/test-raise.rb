#!/usr/bin/env ruby
require 'rubygems'; require 'require_relative'
# require_relative '../../lib/trepanning'
require_relative 'helper'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

# Test Debugger.load handles uncaught exceptions in the debugged program.
class TestRaise < Test::Unit::TestCase
  include TestHelper
  def test_basic
    skip "We get a SEGV here on an unpatched 1.9.2" if 
      RUBY_VERSION =~ /1.9/
    common_setup(__FILE__)
    Dir.chdir(@srcdir) do 
      filter = Proc.new{|got_lines, correct_lines|
        new_lines = []
        got_lines.each do |s|
          new_lines << s unless s == 'x'
        end
        got_lines[0..-1] = new_lines[0..-1]
      }
      assert_equal(true, 
                   run_debugger(@testname, 
                                @prefix + '../example/raise.rb',
                                nil, filter))
    end
  end
end
