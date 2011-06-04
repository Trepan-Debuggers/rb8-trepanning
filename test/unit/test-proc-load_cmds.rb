#!/usr/bin/env ruby
require 'test/unit'
require 'rubygems'; require 'require_relative'
require_relative 'cmd-helper'

class TestCmdProcessorLoadCmds < Test::Unit::TestCase

  include UnitHelper
  def setup
    common_setup
  end

  # See that we have can load up commands
  def test_basic
    @cmdproc.load_cmds_initialize
    assert_equal(false, @cmdproc.commands.empty?)
    assert_equal(false, @cmdproc.aliases.empty?)
  end

  def test_complete
    assert_equal(%w(directory disable display down),
                 @cmdproc.complete('d', 'd'),
                 "Failed completion of 'd' commands")
    assert_equal(['debug', 'different', 'directories'], 
                 @cmdproc.complete('sho d', 'd'),
                 "Failed completion of 'sho d' subcommands")
    $errors = []
  end

  def test_run_cmd
    $errors = []

    def @cmdproc.errmsg(mess)
      $errors << mess
    end

    def test_it(size, *args)
      @cmdproc.run_cmd(*args)
      assert_equal(size, $errors.size, $errors)
    end
    test_it(1, 'foo')
    test_it(2, [])
    test_it(3, ['list', 5])
    # See that we got different error messages
    assert_not_equal($errors[0], $errors[1], $errors)
    assert_not_equal($errors[1], $errors[2], $errors)
    assert_not_equal($errors[2], $errors[0], $errors)
  end

end
