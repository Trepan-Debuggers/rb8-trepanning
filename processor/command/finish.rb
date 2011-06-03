# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative 'base/cmd'

class Trepan::Command::FinishCommand < Trepan::Command

  unless defined?(HELP)
    ALIASES      = %w(fin)
    CATEGORY     = 'running'
    NAME         = File.basename(__FILE__, '.rb')
    HELP         = <<-HELP
#{NAME} [FRAME_NUM]

Execute until selected stack frame returns.

If no frame number is given, we run until the currently selected frame
returns.  The currently selected frame starts out the most-recent
frame or 0 if no frame positioning (e.g "up", "down" or "frame") has
been performed. If a frame number is given we run until that frame
returns.
      HELP
    NEED_RUNNING = true
    SHORT_HELP   = 'Step into next method call or to next line'
  end

  # self.allow_in_post_mortem = false
  # self.need_context         = true
    
  def run(args)
    state = @proc.state
    context = @proc.context
    max_frame = context.stack_size - state.frame_pos
    if args.size == 1
      frame_pos = state.frame_pos
    else
      count_str = args[1]
      count_opts = {
        :msg_on_error => 
        "The '#{NAME}' command argument must eval to an integer. Got: %s" % 
        count_str,
        :min_value => 0,
        :max_valiue => context.stack_size - state.frame_pos
      }
      count = @proc.get_an_int(count_str, count_opts)
      return unless count
      frame_pos = count - 1  
    end
    context.stop_frame = frame_pos
    state.frame_pos = 0
    state.proceed
    @proc.leave_cmd_loop = true
  end
end

if __FILE__ == $0
  require_relative '../mock'
  dbgr, cmd = MockDebugger::setup
  cmd.run([cmd.name])
end
