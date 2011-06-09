# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative 'base/cmd'
require_relative '../stepping'

class Trepan::Command::CatchCommand < Trepan::Command
  unless defined?(HELP)
    NAME = File.basename(__FILE__, '.rb')
    HELP = <<-HELP
#{NAME} EXCEPTION-NAME
#{NAME} EXCEPTION-NAME off
#{NAME} 
#{NAME} off

The first form intercepts EXCEPTION-NAME when.
The second form removes the debugger handling for EXCEPTION-NAME.
The third form is the the same as "info catch".  
The last form deletes all debugger catchpoints.

Examples:
   #{NAME}       # same as "info catch"
   #{NAME} ZeroDivisionError  # Handle dividing by zero exceptions.
   #{NAME} off   # Turns off all debugger exception handling

See also "info catch" and post-mortem debugging.
    HELP

    ALIASES      = %w()
    CATEGORY     = 'running'
    MAX_ARGS     = 2  # Need at most this many
    NEED_RUNNING = true
    SHORT_HELP   = 'Catch exceptions'
  end

  # This is the method that runs the command
  def run(args)
    case args.size
    when 1
      @proc.commands['info'].run(%W(info catch))
    when 2
      exception = args[1]
      if args[1] == 'off'
        Debugger.catchpoints.clear if 
          confirm('Delete all catchpoints?', false)
      else
        unless @proc.debug_eval_no_errmsg("#{exception}.is_a?(Class)")
          msg "Warning #{exception} is not known to be a Class"
        end
        Debugger.add_catchpoint(exception)
        msg "Catch exception %s." % exception
      end
    when 3
      exception = args[1]
      if Debugger.catchpoints.member?(exception)
        Debugger.catchpoints.delete(exception)
        msg "Catch for exception %s removed." % exception
      else
        errmsg "Catch for exception %s not found." % exception
      end
    end
  end
end

if __FILE__ == $0
  require_relative '../mock'
  dbgr, cmd = MockDebugger::setup
  cmd.run([cmd.name])
  cmd.run([cmd.name, 'ZeroDivisionError'])
  cmd.run([cmd.name])
  cmd.run([cmd.name, 'ZeroDivisionError', 'off'])
end
