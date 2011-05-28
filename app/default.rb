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
  
  # Default settings for a Trepan class object
  DEFAULT_SETTINGS = {
    :cmdproc_opts    => {},    # Default Trepan::CmdProcessor settings
    :core_opts       => {},    # Default Trepan::Core settings
    :delete_restore  => true,  # Delete restore profile after reading? 
    :initial_dir     => nil,   # If --cd option was given, we save it here.
    :nx              => false, # Don't run user startup file (e.g. .trepanxrc)
    :offset          => 0,     # skipping back +offset+ frames. This lets you start
                               # the debugger straight into callers method.

    # Default values used only when 'server' or 'client'
    # (out-of-process debugging)
    :port            => 1955,
    :host            => 'localhost', 

    :restart_argv    => [],
    :server          => false  # Out-of-process debugging?
  } unless defined?(DEFAULT_SETTINGS)

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

end

if __FILE__ == $0
  # Show it:
  require 'pp'
  PP.pp(Trepan::CmdProcessor::DEFAULT_SETTINGS)
end
