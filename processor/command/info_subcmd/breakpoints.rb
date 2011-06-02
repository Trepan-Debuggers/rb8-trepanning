# -*- coding: utf-8 -*-
# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::InfoBreakpoints < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP         = <<-EOH
#{PREFIX.join(' ')} [num1 ...]

Show status of user-settable breakpoints. If no breakpoint numbers are
given, the show all breakpoints. Otherwise only those breakpoints
listed are shown and the order given. If VERBOSE is given, more
information provided about each breakpoint.

The "Disp" column contains one of "keep", "del", the disposition of
the breakpoint after it gets hit.

The "enb" column indicates whether the breakpoint is enabled.

The "Where" column indicates where the breakpoint is located.
EOH
    MIN_ABBREV   = 'br'.size
    SHORT_HELP   = 'Status of user-settable breakpoints'
  end
  
  def run(args)
    unless @proc.state.context
      errmsg "info breakpoints not available here."
      return 
    end
    unless Debugger.breakpoints.empty?
      brkpts = Debugger.breakpoints.sort_by{|b| b.id}
      unless args[2..-1].empty?
        a = args.map{|a| a.to_i}
        brkpts = brkpts.select{|b| a.member?(b.id)}
        if brkpts.empty?
          errmsg "No breakpoints found among list given.\n"
          return
        end
      end
      section "Num Enb What"
      brkpts.each do |b|
        fname = settings[:basename] ? 
        File.basename(b.source) : b.source
        
        if b.expr.nil?
          msg "%3d %s   at %s:%s" %  
            [b.id, (b.enabled? ? 'y' : 'n'), fname, b.pos]
        else
          msg "%3d %s   at %s:%s if %s" %  
            b.id, (b.enabled? ? 'y' : 'n'), fname, b.pos, b.expr
        end
        hits = b.hit_count
        if hits > 0
          s = (hits > 1) ? 's' : ''
          msg "\tbreakpoint already hit #{hits} time#{s}\n"
        end
      end
    else
      msg "No breakpoints.\n"
    end
  end
end

if __FILE__ == $0
  # Demo it.
  require_relative '../../mock'
  name = File.basename(__FILE__, '.rb')
  dbgr, cmd = MockDebugger::setup('info')
  subcommand = Trepan::Subcommand::InfoBreakpoints.new(cmd)

  puts '-' * 20
  subcommand.run(%w(info break))
  puts '-' * 20
  subcommand.summary_help(name)
  puts
  puts '-' * 20
end
