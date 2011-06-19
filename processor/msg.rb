# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
# I/O related command processor methods
require 'rubygems'; require 'require_relative'
require_relative '../app/util'
require_relative 'virtual'
module Trepan
  class CmdProcessor < VirtualCmdProcessor
    attr_accessor :ruby_highlighter

    def errmsg(message, opts={})
      message = safe_rep(message) unless opts[:unlimited]
      if @settings[:highlight] && defined?(Term::ANSIColor)
        message = 
          Term::ANSIColor.italic + message + Term::ANSIColor.reset 
      end
      @intf.errmsg(message)
    end

    def msg(message, opts={})
      message = safe_rep(message) unless opts[:unlimited]
      message = ruby_format(message) if opts[:code]
      @intf.msg(message)
    end

    def msg_nocr(message, opts={})
      message = safe_rep(message) unless opts[:unlimited]
      @intf.msg_nocr(message)
    end

    def read_command()
      @intf.read_command(@prompt)
    end

    def ruby_format(text)
      return text unless settings[:highlight]
      unless @ruby_highlighter
        begin
          require 'coderay'
          require 'term/ansicolor'
          @ruby_highlighter = CodeRay::Duo[:ruby, :term]
        rescue LoadError
          return text
        end
      end
      return @ruby_highlighter.encode(text)
    end

    def safe_rep(str)
      Util::safe_repr(str, @settings[:maxstring])
    end

    def section(message, opts={})
      message = safe_rep(message) unless opts[:unlimited]
      if @settings[:highlight] && defined?(Term::ANSIColor)
        message = 
          Term::ANSIColor.bold + message + Term::ANSIColor.reset 
      end
      @intf.msg(message)
    end

  end
end
