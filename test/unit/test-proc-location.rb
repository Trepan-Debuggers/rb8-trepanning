#!/usr/bin/env ruby
require 'test/unit'
require 'rubygems'; require 'require_relative'
require 'ruby-debug'; 
require 'linecache'
require_relative '../../processor/location'
require_relative '../../processor/mock'

$errors = []
$msgs   = []

# Test Trepan::CmdProcessor location portion
class TestCmdProcessorLocation < Test::Unit::TestCase

  def setup
    $errors = []
    $msgs   = []
    @dbgr = MockDebugger::MockDebugger.new
    @proc = Trepan::CmdProcessor.new(@dbgr.intf)
    @file = File.basename(__FILE__)
  end

  # Test resolve_file_with_dir() and line_at()
  def test_line_at
    @proc.settings[:directory] = ''
    assert_equal(nil, @proc.resolve_file_with_dir(@file))
    if File.expand_path(Dir.pwd) == File.expand_path(File.dirname(__FILE__))
      line = @proc.line_at(@file, __LINE__)
      assert_match(/line = @proc.line_at/, line)
    else
      assert_equal(nil, @proc.line_at(@file, __LINE__))
    end
    dir = @proc.settings[:directory] = File.dirname(__FILE__)
    assert_equal(File.join(dir, @file), 
                 @proc.resolve_file_with_dir('test-proc-location.rb'))
    test_line = 'test_line'
    line = @proc.line_at(@file, __LINE__-1)
    assert_match(/#{line}/, line)
  end

  def test_loc_and_text
    @proc.frame_index = 0
    @proc.frame_initialize
    Debugger.start
    @proc.frame_setup(Debugger.current_context, nil)
    LineCache::clear_file_cache
    dir = @proc.settings[:directory] = File.dirname(__FILE__)
    loc, line_no, text = @proc.loc_and_text('hi')
    assert loc and line_no.is_a?(Fixnum) and text 
    assert @proc.current_source_text
    # FIXME test that filename remapping works.
    Debugger.stop
  end

  def test_canonic_file
    @proc.settings[:basename] = false
    assert_equal File.expand_path(__FILE__), @proc.canonic_file(__FILE__)
    @proc.settings[:basename] = true
    assert_equal File.basename(__FILE__), @proc.canonic_file(__FILE__)
  end


  def test_eval_current_source_text
    Debugger.start
    eval <<-EOE
      @proc.frame_index = 0
      @proc.frame_initialize
      @proc.frame_setup(Debugger.current_context, nil)
      LineCache::clear_file_cache
      assert @proc.current_source_text
    EOE
    Debugger.stop
  end

end