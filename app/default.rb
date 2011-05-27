# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
module Trepan
  # Default options to Trepan.start
  DEFAULT_START_SETTINGS = { 
    :init        => true,  # Set $0 and save ARGV? 
    :post_mortem => false, # post-mortem debugging on uncaught exception?
    :tracing     => nil    # Debugger.tracing value. true/false resets,
                           # nil keeps the prior value
  } unless defined?(DEFAULT_START_SETTINGS)

  # the port number used for remote debugging
  PORT = 8989 unless defined?(PORT)

  # What file is used for debugger startup commands.
  unless defined?(CMD_INITFILE_BASE)
    CMD_INITFILE_BASE = 
      if RUBY_PLATFORM =~ /mswin/
        # Of course MS Windows has to be different
        HOME_DIR =  (ENV['HOME'] || 
                     ENV['HOMEDRIVE'].to_s + ENV['HOMEPATH'].to_s).to_s
        'trepan8.ini'
    else
        HOME_DIR = ENV['HOME'].to_s
        '.trepan8rc'
    end
  end

  CMD_INITFILE = File.join(HOME_DIR, CMD_INITFILE_BASE) unless
    defined?(CMD_INITFILE)
  
  # Default settings for Trepan run from the command line.
  DEFAULT_CMDLINE_SETTINGS = {
    'annotate'           => 0,
    'client'             => false,
    'control'            => true,
    'cport'              => PORT + 1,
    'frame_bind'         => false,
    'host'               => nil,
    'quit'               => true,
    'no_rewrite_program' => false,
    'stop'               => true,
    'nx'                 => false,
    'port'               => PORT,
    'post_mortem'        => false,
    'restart_script'     => nil,
    'script'             => nil,
    'server'             => false,
    'tracing'            => false,
    'verbose_long'       => false,
    'wait'               => false
    ## :cmdfiles => [],  # initialization command files to run
    ## :client   => false, # attach to out-of-process program?
    ## :nx       => false, # don't run user startup file (e.g. .trepanrc)
    ## :output   => nil,
    ## :port     => default_settings[:port],
    ## :host     => default_settings[:host], 
    ## :server   => false, # out-of-process debugging?
    ## :readline => true,  # try to use gnu readline?
    ## Note that at most one of :server or :client can be true.
  } unless defined?(DEFAULT_CMDLINE_SETTINGS)

  class CmdProcessor

    DEFAULT_SETTINGS = {
      :autoeval      => true,      # Ruby eval non-debugger commands
      :autoirb       => false,     # Go into IRB in debugger command loop
      :autolist      => false,     # Run 'list' 

      :basename      => false,     # Show basename of filenames only
      :confirm       => true,      # Confirm potentially dangerous operations?
      :different     => 'nostack', # stop *only* when  different position? 

      :debugdbgr     => false,     # Debugging the debugger
      :debugexcept   => true,      # Internal debugging of command exceptions
      :debugmacro    => false,     # debugging macros
      :debugskip     => false,     # Internal debugging of step/next skipping
      :directory     =>            # last-resort path-search for files
                    '$cdir:$cwd',  # that are not fully qualified.

      :hidestack     => nil,       # Fixnum. How many hidden outer
                                   # debugger stack frames to hide?
                                   # nil or -1 means compute value. 0
                                   # means hide none. Less than 0 means show
                                   # all stack entries.
      :hightlight    => false,     # Use terminal highlight? 
      
      :maxlist       => 10,        # Number of source lines to list 
      :maxstack      => 10,        # backtrace limit
      :maxstring     => 150,       # Strings which are larger than this
                                   # will be truncated to this length when
                                   # printed
      :maxwidth       => (ENV['COLUMNS'] || '80').to_i,
      :prompt         => 'trepan', # core part of prompt. Additional info like
                                   # debug nesting and 
      :save_cmdfile  => nil,       # If set, debugger command file to be
                                   # used on restart
      :timer         => false,     # show elapsed time between events
      :traceprint    => false,     # event tracing printing
      :tracebuffer   => false,     # save events to a trace buffer.
      :user_cmd_dir  => File.join(Trepan::HOME_DIR, 'trepan', 'command'),
                                   # User command directory
    }
  end
end

if __FILE__ == $0
  # Show it:
  require 'pp'
  PP.pp(Trepan::CmdProcessor::DEFAULT_SETTINGS)
end
