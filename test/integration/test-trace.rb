#!/usr/bin/env ruby
require 'test/unit'
require 'rubygems'; require 'require_relative'
require_relative 'helper'

class TestTrace < Test::Unit::TestCase
  include TestHelper
  TREPAN_LOC    = /.. \(.+:\d+( @\d+)?\)/
  def test_trepan_trace
    skip "We may get different results on an unpatched 1.9.2" if 
      RUBY_VERSION =~ /1.9/
    common_setup(__FILE__)
    Dir.chdir(@srcdir) do 
      last_line = nil
      filter = Proc.new{|got_lines, correct_lines|
        got_lines.each_with_index do |line, i|
          line.gsub!(/\((?:.*\/)?(.+:\d+)/, '(\1') if line =~ TREPAN_LOC
          if line.start_with?('at_exit')
            last_line = i-2
            break
          end
        end
        got_lines[last_line..-1] = got_lines[last_line] if last_line
      }
      rightfile = File.join(%W(.. data #{@testname}))
      assert_equal(true, run_debugger(@testname, 
                                      "-x #{@prefix}../example/gcd.rb 3 5", 
                                      nil, filter, nil, rightfile))
    end
  end
end
