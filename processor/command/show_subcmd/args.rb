# -*- coding: utf-8 -*-
# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::ShowArgs < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP = 'Show argument list to give program when it is restarted'
    MIN_ABBREV   = 'ar'.size
  end

  def run(args)
    if Trepan::OldCommand.settings[:argv] and Trepan::OldCommand.settings[:argv].size > 0
      if defined?(Trepan::PROG_SCRIPT)
        # rdebug was called initially. 1st arg is script name.
        args = Trepan::OldCommand.settings[:argv][1..-1].join(' ')
      else
        # rdebug wasn't called initially. 1st arg is not script name.
        args = Trepan::OldCommand.settings[:argv].join(' ')
      end
    else
      args = ''
    end
    msg "Argument list to give program being debugged when it is started is \"#{args}\"."
  end
end

if __FILE__ == $0
  # Demo it.
  $0 = __FILE__ + 'notagain' # So we don't run this agin
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::ShowBasename)
end
