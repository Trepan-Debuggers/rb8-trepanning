# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative 'virtual'
module Trepan
  class CmdProcessor  < VirtualCmdProcessor
    def parse_stepping_args(command_name, match)
      if match[1].nil? 
          different = @settings[:force_stepping]
      elsif match[1] == '+' 
        different = true
      elsif match[1] == '-' 
        different = false
      end
      steps = get_int(match[2], command_name, 1)
      return [steps, different]
    end
  end
end
