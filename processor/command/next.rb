# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative 'base/cmd'

class Trepan::Command::NextCommand < Trepan::Command

  ALIASES      = %w(n n+ n- next+)
  CATEGORY     = 'running'
  NAME         = File.basename(__FILE__, '.rb')
  HELP         = <<-HELP
#{NAME}[+|-] [into]  [count]

Attempt to continue execution and stop at the next line. If there is
a conditional branch between the current position and the next line,
execution is stopped within the conditional branch instead.

The optional argument is a number which specifies how many lines to
attempt to skip past before stopping execution.

If the current line is the last in a method, execution is stopped
at the current position of the caller.

See also 'step' and 'nexti'.

Examples: 
  #{NAME}        # next 1 line
  #{NAME} 1      # same as above
  #{NAME}+       # same but force stopping on a new line
  #{NAME}-       # same but force stopping on a new line or a new frame added

Related and similar is the 'step' (step into) and 'finish' (step out)
commands.
      HELP
  NEED_RUNNING = true
  SHORT_HELP   = 'Step into next method call or to next line'

  Keyword_to_related_cmd = {
    'out'  => 'finish',
    'over' => 'next',
    'into' => 'step',
  }
  
  # self.allow_in_post_mortem = false
  # self.need_context         = true
    
  def run(args)
    condition = nil
    opts = {}
    if args.size == 1
      step_count = 1
    else
      replace_cmd = Keyword_to_related_cmd[args[1]]
      if replace_cmd
        cmd = @proc.commands[replace_cmd]
        return cmd.run([replace_cmd] + args[2..-1])
      end
      step_str = args[1]
      opts = @proc.parse_next_step_suffix(args[0])
      count_opts = {
        :msg_on_error => 
        "The #{NAME} command argument must eval to an integer. Got: %s" % 
        step_str,
        :min_value => 1
      }
      step_count = @proc.get_an_int(step_str, count_opts)
      return unless step_count
    end
    ## @proc.state.context.step(step_count, force)
    @proc.context.step_over(step_count, @proc.state.frame_pos, 
                            opts[:different_pos])
    @proc.state.proceed
    @proc.leave_cmd_loop = true
  end
end

if __FILE__ == $0
  require_relative '../mock'
  dbgr, cmd = MockDebugger::setup
end
