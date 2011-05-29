# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../base/subcmd'

class Trepan::Subcommand::InfoFiles < Trepan::Subcommand
  unless defined?(HELP)
    Trepanning::Subcommand.set_name_prefix(__FILE__, self)
    HELP         = 'Show files cached by the debugger'
    MIN_ABBREV   = 'files'.size
    NEED_STACK   = false
    MIN_ARGS     = 0
    MAX_ARGS     = 0
    NEED_STACK   = true
   end

  def run(args)
    files = LineCache::cached_files
    files += SCRIPT_LINES__.keys unless 'stat' == args[0] 
    files.uniq.sort.each do |file|
      stat = LineCache::stat(file)
      path = LineCache::path(file)
      print "File %s" % file
      if path and path != file
        msg(" - %s" % path)
      else
        msg ''
      end
      msg(("\t%s" % stat.mtime)) if stat
    end
  end
end

if __FILE__ == $0
  # Demo it.
  $0 = __FILE__ + 'notagain' # So we don't run this again
  require_relative '../../mock'
  cmd = MockDebugger::sub_setup(Trepan::Subcommand::InfoFiles, false)
  cmd.run(cmd.prefix)
end
