# -*- coding: utf-8 -*-
# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rbconfig'
require 'rubygems'; require 'require_relative'
module Trepan

  module_function # All functions below are easily publically accessible

  # Given a Ruby interpreter and program we are to debug, debug it.
  # The caller must ensure that ARGV is set up to remove any debugger
  # arguments or things that the debugged program isn't supposed to
  # see.  FIXME: Should we make ARGV an explicit parameter?

  def debug_program(ruby_path, options)
    # Make sure Ruby script syntax checks okay.
    # Otherwise we get a load message that looks like trepan8 has 
    # a problem. 
    output = `#{ruby_path} -c #{Trepan::PROG_SCRIPT.inspect} 2>&1`
    if $?.exitstatus != 0 and RUBY_PLATFORM !~ /mswin/
      puts output
      exit $?.exitstatus 
    end

    %w(highlight basename).each do |opt|
      opt = opt.to_sym
      Debugger.handler.cmdproc.settings[opt] = options[opt]
    end

    # Record where we are we can know if the call stack has been
    # truncated or not.
    Trepan.start_sentinal=caller(0)[1]

    bt = Debugger.debug_load(Trepan::PROG_SCRIPT, options[:stop], false)
    if bt
      if options[:post_mortem]
        Debugger.handle_post_mortem(bt)
      else
        print bt.backtrace.map{|l| "\t#{l}"}.join("\n"), "\n"
        print "Uncaught exception: #{bt}\n"
      end
    end
  end

  # Do a shell-like path lookup for prog_script and return the results.
  # If we can't find anything return prog_script.
  def whence_file(prog_script)
    if prog_script.index(File::SEPARATOR)
      # Don't search since this name has path separator components
      return prog_script
    end
    for dirname in ENV['PATH'].split(File::PATH_SEPARATOR) do
      prog_script_try = File.join(dirname, prog_script)
      return prog_script_try if File.readable?(prog_script_try)
    end
    # Failure
    return prog_script
  end
end

# Path name of Ruby interpreter we were invoked with. Is part of 
# 1.9 but not necessarily 1.8.
def RbConfig.ruby
  File.join(RbConfig::CONFIG['bindir'],  
            RbConfig::CONFIG['RUBY_INSTALL_NAME'] + 
            RbConfig::CONFIG['EXEEXT'])
end unless defined? RbConfig.ruby

if __FILE__ == $0
  # Demo it.
  include  Trepan
  puts whence_file('irb')
  puts whence_file('probably-does-not-exist')
  puts RbConfig.ruby
end
