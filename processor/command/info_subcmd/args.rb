# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::InfoArgs < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP         = 'Show argument variables of the current stack frame'
    MIN_ABBREV   = 'ar'.size
    MIN_ARGS     = 0
    MAX_ARGS     = 0
    NEED_STACK   = true
   end

  def run(args)
    state = @proc.state
    context = @proc.context
    locals = context.frame_locals(state.frame_pos)
    args = context.frame_args(state.frame_pos)
    if args.empty?
      msg "argument list is empty"
    else
      args.each do |name|
        s = "#{name} = #{locals[name].inspect}"
        if s.size > @proc.settings[:maxwidth]
          s[@proc.settings[:maxwidth]-3 .. -1] = "..."
        end
        msg "#{s}\n"
      end
    end
  end
end

if __FILE__ == $0
  # Demo it.
  $0 = __FILE__ + 'notagain' # So we don't run this again
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::InfoArgs, false)
  cmd.run(cmd.prefix)
end
