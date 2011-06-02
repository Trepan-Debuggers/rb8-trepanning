# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative './base/cmd'

class Trepan::Command::BreakCommand < Trepan::Command

  ALIASES      = %w(b)
  CATEGORY     = 'breakpoints'
  NAME         = File.basename(__FILE__, '.rb')
  HELP         = <<-HELP
#{NAME} LOCATION [ {if|unless} CONDITION ]

Set a breakpoint. In the second form where CONDITIOn is given, the
condition is evaluated in the context of the position. We stop only If
CONDITION evalutes to non-false/nil and the "if" form used, or it is
false and the "unless" form used.\

Examples:
   #{NAME}
   #{NAME} 10               # set breakpoint on line 10
   #{NAME} 10 if 1 == a     # like above but only if a is equal to 1
   #{NAME} 10 unless 1 == a # like above but only if a is equal to 1
   #{NAME} me.rb:10
   #{NAME} Kernel.pp # Set a breakpoint at the beginning of Kernel.pp

See also condition, continue and "help location".
      HELP
  SHORT_HELP   = 'Set a breakpoint at a point in a method'

  # This method runs the command
  def run(args, temp=false)

    arg_str = args.size == 1 ? @proc.frame.line.to_s : @proc.cmd_argstr
    cm, file, line, position_type = 
      @proc.parse_position(arg_str)
    if file.nil?
      unless @proc.context
        errmsg "We are not in a state that has an associated file.\n"
        return 
      end
      file = @proc.frame.file
      if line.nil? 
        # Set breakpoint at current line
        line = @proc.frame.line.to_s
      end
    end
    
    if line
      if LineCache.cache(file, settings[:reload_source_on_change])
        last_line = LineCache.size(file)
        if line > last_line
          errmsg("There are only %d lines in file \"%s\"." % [last_line, 
                 @proc.canonic_file(file)]) 
          return
        end
        unless LineCache.trace_line_numbers(file).member?(line)
          errmsg("Line %d is not a stopping point in file \"%s\"." % 
                 [line, @proc.canonic_file(file)])
          return
        end
      else
        errmsg("No source file named %s\n" % @proc.canonic_file(file))
        return unless confirm("Set breakpoint anyway? (y/n) ", false)
      end
      
      unless @proc.context
        errmsg "We are not in a state we can add breakpoints.\n"
        return 
      end

      expr = nil
      if temp
        @proc.state.context.set_breakpoint(file, line)
        msg("Temporary breakpoint set at file %s, line %d" % [file, line])
      else        
        b = Debugger.add_breakpoint file, line, expr
        msg("Breakpoint %d file %s, line %d" % [b.id, file, line])
      end
    #   unless syntax_valid?(expr)
    #     errmsg("Expression \"#{expr}\" syntactically incorrect; breakpoint disabled.\n")
    #     b.enabled = false
    #   end
    # else
    #   method = line.intern.id2name
    #   b = Debugger.add_breakpoint class_name, method, expr
    #   print "Breakpoint %d at %s::%s\n", b.id, class_name, method.to_s
    end
  end
end

if __FILE__ == $0
  require_relative '../mock'
  dbgr, cmd = MockDebugger::setup
  # require_relative '../../lib/trepanning'
  def run_cmd(cmd, args) 
    cmd.proc.instance_variable_set('@cmd_argstr', args[1..-1].join(' '))
    cmd.run(args)
  end

  run_cmd(cmd, [cmd.name, 2])
  # run_cmd(cmd, [cmd.name])
  # run_cmd(cmd, [cmd.name, __LINE__.to_s])

  # def foo
  #   5 
  # end
  # run_cmd(cmd, [cmd.name, 'foo', (__LINE__-2).to_s])
  # run_cmd(cmd, [cmd.name, 'foo'])
  # run_cmd(cmd, [cmd.name, "MockDebugger::setup"])
  # require 'irb'
  # run_cmd(cmd, [cmd.name, "IRB.start"])
  # run_cmd(cmd, [cmd.name, 'foo93'])
end
