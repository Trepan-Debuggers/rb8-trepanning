# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::InfoThreads < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP         = 'Show IDs of currently-known threads'
    MIN_ABBREV   = 'th'.size
    MIN_ARGS     = 0
    MAX_ARGS     = 0
    NEED_STACK   = true
  end
  
  def display_context(c, show_top_frame=true)
    c_flag = c.thread == Thread.current ? '+' : ' '
    c_flag = '$' if c.suspended?
    d_flag = c.ignored? ? '!' : ' '
    str  = "%s%s" % [c_flag, d_flag]
    str += "%d " % c.thnum
    str += "%s\t" % c.thread.inspect
    if c.stack_size > 0 and show_top_frame
      str += "%s:%d" % [@proc.canonic_file(c.frame_file(0)), c.frame_line(0)]
    end
    msg str
  end
  
  def get_context(thnum)
    Debugger.contexts.find{|c| c.thnum == thnum}
  end  
  
  def parse_thread_num(subcmd, arg)
    if '' == arg
      errmsg "'%s' needs a thread number\n" % subcmd
      nil
    else
      thread_num = @proc.get_int(arg, 
                                 :cmdname => "thread #{subcmd}", 
                                 :default => 1)
      return nil unless thread_num
      get_context(thread_num)
    end
  end
  
  def parse_thread_num_for_cmd(subcmd, arg)
    c = parse_thread_num(subcmd, arg)
    return nil unless c
    case 
    when nil == c
      errmsg "No such thread."
    when @proc.context == c
      errmsg "It's the current thread."
    when c.ignored?
      errmsg "Can't #{subcmd} to the debugger thread #{arg}."
    else # Everything is okay
      return c
    end
    return nil
  end
  
  def run(args)
    threads = Debugger.contexts.sort_by{|c| c.thnum}.each do |c|
      display_context(c)
    end
  end
end

if __FILE__ == $0
  # Demo it.
  $0 = __FILE__ + 'notagain' # So we don't run this again
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::InfoThreads, false)
  cmd.run(cmd.prefix)
end
