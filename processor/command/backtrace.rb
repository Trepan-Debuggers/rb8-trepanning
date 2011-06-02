require 'rubygems'; require 'require_relative'
require_relative './base/cmd'

class Trepan::Command::BacktraceCommand < Trepan::Command
  unless defined?(ALIASES)
    ALIASES      = %w(bt where)
    CATEGORY     = 'stack'
    MAX_ARGS     = 2 # Need at most this many
    NAME         = File.basename(__FILE__, '.rb')
    HELP = <<-HELP
#{NAME}

Print the entire stack frame. Each frame is numbered, the most recent
frame is 0. frame number can be referred to in the "frame" command;
"up" and "down" add or subtract respectively to frame numbers shown.
The position of the current frame is marked with -->. 

See also 'set hidelevel'.
      HELP
    NEED_STACK   = true
    SHORT_HELP   =  'Show the current call stack'
  end
  
  def complete(prefix)
    @proc.frame_complete(prefix, nil)
  end
  
  def print_frame(pos, adjust = false, context=@proc.state.context)
    frame = @proc.frame
    file  = frame.file
    line  = frame.line
    klass = frame.klass
    
    frame_num = "#%d " % pos
    opts = {
      :maxwidth  => settings[:maxwidth],
      :callstyle => settings[:callstyle]
    }

    # FIXME There seem to be bugs in showing call if
    # pos != 0
    call_str = (pos == 0) ? @proc.frame.call_string(opts) : ''

    file_line = "at line %s:%d" % [@proc.canonic_file(file), line]
    str = frame_num
    unless call_str.empty?
      str += call_str + ' '
      if call_str.size + frame_num.size + file_line.size > settings[:maxwidth]
        str += "\n       "
      end
    end
    str += file_line
    str
  end
  
  # Check if call stack is truncated.  This can happen if
  # Trepan.start is not called low enough in the call stack. An
  # array of additional callstack lines from caller is returned if
  # definitely truncated, false if not, and nil if we don't know.
  #
  # We determine truncation based on a passed in sentinal set via
  # caller which can be nil.  
  #
  # First we see if we can find our position in caller. If so, then
  # we compare context position to that in caller using sentinal
  # as a place to start ignoring additional caller entries. sentinal
  # is set by rdebug, but if it's not set, i.e. nil then additional
  # entries are presumably ones that we haven't recorded in context
  def truncated_callstack?(context, sentinal=nil, cs=caller)
    frame = @proc.frame
    recorded_size = context.stack_size
    to_find_fl = "#{frame.file}:#{frame.line}"
    top_discard = false
    cs.each_with_index do |fl, i|
      fl.gsub!(/in `.*'$/, '')
      fl.gsub!(/:$/, '')
      if fl == to_find_fl
        top_discard = i
        break 
      end
    end
    if top_discard
      cs = cs[top_discard..-1]
      return false unless cs
      return cs unless sentinal
      if cs.size > recorded_size+2 && cs[recorded_size+2] != sentinal 
        # caller seems to truncate recursive calls and we don't.
        # See if we can find sentinal in the first 0..recorded_size+1 entries
        return false if cs[0..recorded_size+1].any?{ |f| f==sentinal }
        return cs
      end
      return false
    end
    return nil
  end
  
  # This method runs the command
  def run(args)
    save_index = @proc.frame.index
    (0...@proc.stack_size).each do |idx|
      @proc.frame.index = idx
      if idx == save_index
        str = '--> '
      else
        str = '    '
      end
      str += print_frame(idx)
      msg str
    end
    @proc.frame.index = save_index
    if truncated_callstack?(@proc.state.context, Trepan.start_sentinal)
      msg "Warning: saved frames may be incomplete;"
      msg "compare debugger backtrace (bt) with Ruby caller(0)." 
    end
  end
end

if __FILE__ == $0
  # Demo it.
  require_relative '../mock'
  dbgr, cmd = MockDebugger::setup
  cmd.run([cmd.name])
end
