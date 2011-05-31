# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems'; require 'require_relative'
require_relative '../app/complete'
require_relative '../app/frame'
require_relative '../app/util'
require_relative 'virtual'
class Trepan::CmdProcessor < Trepan::VirtualCmdProcessor

  include Trepan::Util
  attr_reader   :current_thread
  
  # ThreadFrame, current frame
  attr_accessor :frame
  
  # frame index in a "backtrace" command
  attr_accessor :frame_index
  attr_reader   :hide_level
  
  # Hash[thread_id] -> FixNum, the level of the last frame to
  # show. If we called the debugger directly, then there is
  # generally a portion of a backtrace we don't want to show. We
  # don't need to store this for all threads, just those we want to
  # hide frame on. A value of 1 means to hide just the oldest
  # level. The default or showing all levels is 0.
  attr_accessor :hidelevels
  
  # Hash[container] -> file container. This gives us a way to map non-file
  # container objects to a file container for display.
  attr_accessor :remap_container
  
  attr_accessor :stack_size
  
  # top frame of current thread.
  attr_accessor :top_frame       
  # attr_reader   :threads2frames  # Hash[thread_id] -> top_frame
    

  def adjust_frame(frame_num, absolute_pos)
    frame, frame_num = get_frame(frame_num, absolute_pos)
    if frame 
      @frame = frame
      @frame_index = frame_num
      prefix = "--> ##{frame_num} " 
      unless @settings[:traceprint]
        msg("#{prefix}%s" %
            @frame.describe(:basename  => settings[:basename],
                            :maxwidth  => settings[:maxwidth] - prefix.size,
                            :callstyle => settings[:callstyle]))
      end
      @line_no = @frame.line
      @frame
    else
      nil
    end
  end
  
  def frame_low_high(direction)
    if direction
      low, high = [ @frame_index * -direction, 
                    (@stack_size - 1 - @frame_index) * direction ]
      low, high = [high, low] if direction < 0
      [low, high]
    else
      [-@stack_size, @stack_size-1]
    end
  end
  
  def frame_complete(prefix, direction)
    low, high = frame_low_high(direction)
    ary = (low..high).map{|i| i.to_s}
    Trepan::Complete.complete_token(ary, prefix)
  end
  
  # Initializes the thread and frame variables: @frame, @top_frame, 
  # @frame_index, @current_thread, and @threads2frames
  def frame_setup(context, state)
    @frame_index        = 0
    @frame = @top_frame = Trepan::Frame.new(context, state)
    @current_thread     = @frame.thread
    @context            = context
    @state              = state
    @line_no            = @frame.line
    
    @threads2frames   ||= {} 
    @threads2frames[@current_thread] = @top_frame
    @stack_size         = @frame.stack_size
    ## FIXME: reinstate
    ## set_hide_level
  end
  
  # Remove access to thread and frame variables
  def frame_teardown
    @top_frame = @frame = @frame_index = @current_thread = nil 
    @threads2frames = {}
  end
  
  def frame_initialize
    @remap_container = {}
    @remap_iseq      = {}
    @hidelevels      = Hash.new(nil) 
    @hide_level      = 0
  end
  
  def get_frame(frame_num, absolute_pos)
    if absolute_pos
      frame_num += @stack_size if frame_num < 0
    else
      frame_num += @frame_index
    end
    
    if frame_num < 0
      errmsg('Adjusting would put us beyond the newest frame.')
      return [nil, nil]
    elsif frame_num >= @stack_size
      errmsg('Adjusting would put us beyond the oldest frame.')
      return [nil, nil]
    end

    @state.frame_pos = frame_num
    [frame, frame_num]
  end
  
  def parent_frame
    frame = @dbgr.frame(@frame.number + 1)
    unless frame
      errmsg "Unable to find parent frame at level #{@frame.number+1}"
      return nil
    end
    frame
  end
  
  def set_hide_level
    max_stack_size = @context.stack_size
    @hide_level = 
      if !@settings[:hidelevel] || @settings[:hidelevel] < 0
        @settings[:hidelevel] = @hidelevels[@current_thread] =  
          find_main_script(@frame) || max_stack_size
      else
        @settings[:hidelevel]
      end
    @stack_size = if @hide_level >= max_stack_size  
                    max_stack_size else max_stack_size - @hide_level
                  end
  end
end

if __FILE__ == $0
  # Demo it.
  class Trepan::CmdProcessor
    def print_location
      puts "frame location: #{frame.file} #{frame.line}"
    end
  end

  require_relative './mock'
  puts "To be continued..."
  exit
  dbgr, cmd = MockDebugger::setup('exit', false)
  # require_relative '../lib/trepanning'
  # Trepan.start(:set_restart => true)
  proc  = cmd.proc
  0.upto(proc.stack_size-1) { |i| proc.adjust_frame(i, true) }
  puts '*' * 10
  proc.adjust_frame(-1, true)
  proc.adjust_frame(0, true)
  puts '*' * 10
  proc.stack_size.times { proc.adjust_frame(1, false) }
  puts '*' * 10
  proc.adjust_frame(proc.stack_size-1, true)
  proc.stack_size.times { proc.adjust_frame(-1, false) }
    
end
