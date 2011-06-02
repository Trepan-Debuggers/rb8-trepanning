# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative 'base/cmd'
## require_relative '../../app/run'
class Trepan::Command::RestartCommand < Trepan::Command

  unless defined?(HELP)
    NAME         = File.basename(__FILE__, '.rb')
    ALIASES      = %w(R run)
    HELP = <<-HELP
#{NAME} 

Restart debugger and program via an exec call. All state is lost, and
new copy of the debugger is used.
    HELP
    
    CATEGORY     = 'running'
    MAX_ARGS     = nil  # Need at most this many
    SHORT_HELP  = '(Hard) restart of program via exec()'
  end
    
  # This method runs the command
  def run(args)
    if not defined? Trepan::PROG_SCRIPT
      errmsg "Don't know name of debugged program"
      return
    end
    prog_script = Trepan::PROG_SCRIPT
    if not defined? Trepan::PROG_UNRESOLVED_SCRIPT
      # FIXME? Should ask for confirmation? 
      msg "Debugger was not called from the outset..."
      trepan8_script = prog_script
    else 
      trepan8_script = Trepan::PROG_UNRESOLVED_SCRIPT
    end
    begin
      Dir.chdir(Trepan::INITIAL_DIR)
    rescue
      print "Failed to change initial directory #{Trepan::INITIAL_DIR}"
    end
    if not File.exist?(File.expand_path(prog_script))
      errmsg "Ruby program #{prog_script} doesn't exist\n"
      return
    end
    if not File.executable?(prog_script) and trepan8_script == prog_script
      print "Ruby program #{prog_script} doesn't seem to be executable...\n"
      print "We'll add a call to Ruby.\n"
      ruby = begin defined?(Gem) ? Gem.ruby : "ruby" rescue "ruby" end
      trepan8_script = "#{ruby} -I#{$:.join(' -I')} #{prog_script}"
    else
      trepan8_script += ' '
    end
    if args.size == 1
      if not defined? Trepan::OldCommand.settings[:argv]
        errmsg "Arguments have not been set. Use 'set args' to set them."
        return
      else
        argv = Trepan::OldCommand.settings[:argv]
      end
    else
      argv = [prog_script] + args[1..-1]
    end
    args = argv.join(' ')
    
    # An execv would be preferable to the "exec" below.
    cmd = trepan8_script + args
    msg "Re exec'ing:\n\t#{cmd}"
    exec cmd
  rescue Errno::EOPNOTSUPP
    msg "Restart command is not available at this time."
  end
end

if __FILE__ == $0
  exit if ARGV[-1] == 'exit'
  require_relative '../mock'
  dbgr, cmd = MockDebugger::setup
  dbgr.restart_argv = []
  cmd.run([cmd.name])
  dbgr.restart_argv = ARGV + ['exit']
  # require_relative '../../debugger'
  # Trepan.start
  cmd.run([cmd.name])
end
