# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative './base/cmd'

class Trepan::Command::ListCommand < Trepan::Command
  unless defined?(HELP)
    NAME = File.basename(__FILE__, '.rb')
    HELP = <<-HELP
#{NAME} 
#{NAME} -
#{NAME} =
#{NAME} mm-nn

#{NAME} source code. 

In the first form without arguments, prints lines starting at
the line. If this is the first #{NAME} command issued since the debugger
command loop was entered, then the current line is the current
frame. If a subsequent #{NAME} command was issued with no intervening
frame changing, then that is start the line after we last one
previously shown.

In the second form, list lines before the preciding list or
the current line.

In the third form, list lines centered around the current line.

Use 'set max list' or 'show max list' to see or set the value.
    HELP

    ALIASES       = %W(l)
    CATEGORY      = 'files'
    MAX_ARGS      = 2
    SHORT_HELP    = 'List source code'
  end

  # Show FILE from line B to E where CURRENT is the current line number.
  # If we can show from B to E then we return B, otherwise we return the
  # previous line @state.previous_line.
  def display_list(b, e, file, current)
    lines = LineCache::getlines(file, settings[:reload_source_on_change])
    if lines
      b = lines.size - (e - b) if b >= lines.size
      e = lines.size if lines.size < e
      msg "[%d, %d] in %s" % [b, e, file]
      [b, 1].max.upto(e) do |n|
        if n > 0 && lines[n-1]
          if n == current
            msg "=> %3d  %s" % [n, lines[n-1].chomp]
          else
            msg "   %3d  %s" % [n, lines[n-1].chomp]
          end
        end
      end
    else
      errmsg "No sourcefile available for %s\n" % file
      return @state.previous_line
    end
    return b
  end

  def run(args)
    listsize = settings[:maxlist]
    if args.size == 1
      b = @proc.state.previous_line ? 
      @proc.state.previous_line + listsize : @proc.state.line - (listsize/2)
      e = b + listsize - 1
    elsif args[1] == '-'
      b = if @proc.state.previous_line
            if  @proc.state.previous_line > 0
              @proc.state.previous_line - listsize 
            else
              @proc.state.previous_line
            end
          else 
            @proc.state.line - (listsize/2)
          end
      e = b + listsize - 1
    elsif args[1] == '='
      @proc.state.previous_line = nil
      b = @proc.state.line - (listsize/2)
      e = b + listsize -1
    else
      b, e = @args[1].split(/[-,]/)
      if e
        b = b.to_i
        e = e.to_i
      else
        b = b.to_i - (listsize/2)
        e = b + listsize - 1
      end
    end
    @proc.state.previous_line = display_list(b, e, @proc.state.file, @proc.state.line)
  end
  
end

if __FILE__ == $0
  require_relative '../mock'
  dbgr, cmd = MockDebugger::setup
  cmd.run [cmd.name] if ARGV.size > 0
end
