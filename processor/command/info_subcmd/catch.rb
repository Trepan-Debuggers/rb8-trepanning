# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::InfoCatch < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP         = 'Show argument variables of the current stack frame'
    MIN_ABBREV   = 'cat'.size
    MIN_ARGS     = 0
    MAX_ARGS     = 0
    NEED_STACK   = true
   end

  def run(args)
    if Debugger.catchpoints and not Debugger.catchpoints.empty?
      # FIXME: show whether Exception is valid or not
      # print "Exception: is_a?(Class)\n"
      Debugger.catchpoints.each do |exception, hits|
        # print "#{exception}: #{exception.is_a?(Class)}\n"
        msg "#{exception}\n"
      end
    else
      msg "No exceptions set to be caught."
    end
  end
end

if __FILE__ == $0
  # Demo it.
  $0 = __FILE__ + 'notagain' # So we don't run this again
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::InfoProgram, false)
  ## cmd.run(cmd.prefix)
end
