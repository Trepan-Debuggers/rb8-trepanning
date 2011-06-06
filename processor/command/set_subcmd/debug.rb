# -*- coding: utf-8 -*-
# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'
require_relative '../../../interface/script'

class Trepan::Subcommand::SetDebug < Trepan::SetBoolSubcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP         = <<-EOH
#{PREFIX.join(' ')} [on|off|testing]
    EOH

    IN_LIST      = true
    MIN_ABBREV   = 'deb'.size
    SHORT_HELP   = "Set debugger testing."
  end

  completion %w(on off testing)

  def run(args)
    if args.size == 3 && 'testing' == args[2]
      @proc.settings[:debuggertesting] = true
      @proc.settings[:basename] = true
      intf = @proc.intf
      if intf.kind_of?(Trepan::ScriptInterface)
        intf.opts[:verbose] = true
        intf.opts[:basename] = true
        intf.output = STDOUT
        intf.opts[:abort_on_error] = false
      end
      msg("debugger testing is on.")
    else
      super
    end
  end

end

if __FILE__ == $0
  # Demo it.
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::SetDebug)
  cmd.run(cmd.prefix + ['off'])
  cmd.run(cmd.prefix + ['testing'])
  puts cmd.save_command
end
