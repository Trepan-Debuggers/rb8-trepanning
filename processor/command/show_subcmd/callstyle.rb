# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::ShowCallstyle < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP       = "Show confirm potentially dangerous operations setting"
    MIN_ABBREV = 'call'.size
  end

  def run(args)
    msg("Frame call-display style is #{settings[:callstyle]}.")
  end
end

if __FILE__ == $0
  # Demo it.
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::ShowCallstyle, false)
end
