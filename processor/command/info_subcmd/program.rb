# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::InfoProgram < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP         = 'Show argument variables of the current stack frame'
    MIN_ABBREV   = 'pr'.size
    MIN_ARGS     = 0
    MAX_ARGS     = 0
    NEED_STACK   = true
   end

  def run(args)
    if not @proc.context
      errmsg 'The program being debugged is not being run.'
      return
    elsif @proc.context.dead? 
      print "The program crashed.\n"
      if Debugger.last_exception
        msg "Exception: #{Debugger.last_exception.inspect}"
      end
      return
    end
    
    msg "Program stopped. "
    event_arg = @proc.state.processor.event_arg
    case @proc.context.stop_reason
    when :step
      msg "It stopped after stepping, next'ing or initial start."
    when :breakpoint
      msg("It stopped at breakpoint %d.\n" %
            (Debugger.breakpoints.index(event_arg)+1))
    when :catchpoint
      msg("It stopped at catchpoint `%s' (%s) .\n", event_arg,  
            event_arg.class)
    else
      msg "unknown reason: %s\n" % @proc.context.stop_reason.to_s
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
