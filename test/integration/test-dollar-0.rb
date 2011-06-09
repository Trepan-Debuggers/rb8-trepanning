#!/usr/bin/env ruby
require 'rubygems'; require 'require_relative'
# require_relative '../../lib/trepanning'
require_relative 'helper'

# Test --no-stop and $0 setting.
class TestDollar0 < Test::Unit::TestCase
  include TestHelper
  def test_basic
    common_setup(__FILE__)
    Dir.chdir(@srcdir) do 
      home_save = ENV['HOME']
      ENV['HOME'] = '.'
      filter = Proc.new{|got_lines, correct_lines|
        [got_lines, correct_lines].flatten.each do |s|
          s.gsub!(/.*dollar-0.rb$/, 'dollar-0.rb')
        end
      }

      @prefix = '--nx --basename --no-stop '
      %w(dollar-0 dollar-0a dollar-0b).each do |testname|
        assert_equal(true, 
                     run_debugger(testname,
                                  @prefix + 
                                  File.join(%w(.. example dollar-0.rb)),
                                  nil, filter, false, '../bin/trepan8'))
      end
      ENV['HOME'] = home_save
    end
  end
end
