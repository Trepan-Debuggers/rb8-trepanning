# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::SetCallstyle < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    MIN_ABBREV   = 'call'.size
    MAX_ARGS     = 1
    SHORT_HELP   = 'Set how you want call parameters displayed'
    HELP         = <<-EOH
#{CMD} {short|last|tracked}

Set how you want call parameters displayed in a backtrace.
    EOH
  end

  def complete(prefix)
    Trepan::Complete.complete_token(%w(short last tracked), prefix)
  end

  def run(args)
    arg = args[2].downcase.to_sym
    case arg
    when :short, :last, :tracked
      settings[:callstyle] = arg
      Debugger.track_frame_args = (arg == :tracked) ? true : false
      @proc.commands['show'].run(%w(show callstyle))
      return
    else
      errmsg "Invalid call style #{arg}. Should be one of: " +
        "'short', 'last', or 'tracked'."
    end
  end
end

if __FILE__ == $0
  # Demo it.
  $0 = __FILE__ + 'notagain' # So we don't run this again
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::SetCallstyle, false)
  %w(short last tracked).each do |arg|
    cmd.run(cmd.prefix + [arg])
  end
end
