# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'


class Trepan::Subcommand::InfoLine < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP = 'Line number and file name of current position in source file'
    MIN_ABBREV   = 'li'.size
    NEED_STACK   = true
   end

  def run(args)
    unless @proc.state.context
      errmsg "info line not available here."
      return 
    end
    frame = @proc.frame
    msg "Line %d of \"%s\"" %  [frame.line, @proc.canonic_file(frame.file)]
  end
end

if __FILE__ == $0
  # Demo it.
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::InfoLine, false)
  cmd.run(cmd.prefix)
end
