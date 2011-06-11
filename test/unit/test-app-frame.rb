#!/usr/bin/env ruby
require 'test/unit'
require 'rubygems'; require 'require_relative'
require_relative '../../app/frame'

class TestAppFrame < Test::Unit::TestCase
  def test_basic
    require 'rubygems'
    require 'ruby-debug-base'; Debugger.start
    skip "Things are different on an unpatched 1.9.2" if 
      RUBY_VERSION =~ /1.9.2/
    x = 1
    Debugger.skip do 
      frame = Trepan::Frame.new(Debugger.current_context)
      assert_equal __LINE__-2, frame.line
      assert frame.stack_size >= 2, "Frame size should be >= 2, is #{frame.stack_size}"
      assert_equal 'skip', frame.method_name
      assert_equal __FILE__, frame.file
      assert_equal 0, frame.index
      assert_equal Debugger, frame.klass
      assert_equal 1, eval('x', frame.binding)
      frame.index = 1
      assert_equal 'test_basic', frame.method_name
      assert_equal __FILE__, frame.file
      assert_equal Thread.current, frame.thread
      assert_equal self.class, frame.klass
      assert_equal 1, eval('x', frame.binding)
    end
    Debugger.stop
  end

end
