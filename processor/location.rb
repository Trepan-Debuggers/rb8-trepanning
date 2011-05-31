# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'pathname'  # For cleanpath
require 'rubygems'; 
require 'linecache'
require 'require_relative'
# require_relative 'disassemble'
require_relative 'msg'
# require_relative 'frame'
# require_relative '../app/file'
require_relative 'virtual'
class Trepan::CmdProcessor < Trepan::VirtualCmdProcessor
  
  # include Trepanning::FileName
  attr_accessor :reload_on_change
  
  def location_initialize
    @reload_on_change = nil
  end
  
  def canonic_file(filename, resolve=true)
    # For now we want resolved filenames 
    if @settings[:basename] 
      File.basename(filename)
    elsif resolve
      filename = LineCache::unmap_file(filename)
      if File.exist?(filename) 
        filename
#        elsif (try_filename = find_load_path(filename))
#          try_filename
      elsif (try_filename = resolve_file_with_dir(filename))
        try_filename
      else
        File.expand_path(Pathname.new(filename).cleanpath.to_s)
      end
    else
      filename
    end
  end
  
  # Return the text to the current source line.
  def current_source_text
    LineCache::getline(@frame.file, @frame.line)
  end
  
  def resolve_file_with_dir(path_suffix)
    settings[:directory].split(/:/).each do |dir|
      dir = 
        if '$cwd' == dir
          Dir.pwd
        else
          dir
        end
      next unless dir && File.directory?(dir)
      try_file = File.join(dir, path_suffix)
      return try_file if File.readable?(try_file)
    end
    nil
  end
  
  # Get line +line_number+ from file named +filename+. Return "\n"
  # there was a problem. Leading blanks are stripped off.
  def line_at(filename, line_number, 
              opts = {
                :reload_on_change => @reload_on_change,
                :output => @settings[:highlight]
              })
    # We use linecache first to give precidence to user-remapped
    # file names
    line = LineCache::getline(filename, line_number, opts)
    unless line
      # Try using search directories (set with command "directory")
      if filename[0..0] != File::SEPARATOR
        try_filename = resolve_file_with_dir(filename) 
        if try_filename && 
            line = LineCache::getline(try_filename, line_number, opts) 
          LineCache::remap_file(filename, try_filename)
        end
      end
    end
    return nil unless line
    return line.lstrip.chomp
  end
  
  # def loc_and_text(loc, opts=
  #                  {:reload_on_change => @reload_on_change,
  #                    :output => @settings[:highlight]
  #                  })
  
  #   vm_location = @frame.vm_location
  #   filename = vm_location.method.active_path
  #   line_no  = @frame.line
  #   static   = vm_location.static_scope
  #   opts[:compiled_method] = top_scope(@frame.method)
  
  #   if @frame.eval?
  #     file = LineCache::map_script(static.script)
  #     text = LineCache::getline(static.script, line_no, opts)
  #     loc += " remapped #{canonic_file(file)}:#{line_no}"
  #   else
  #     text = line_at(filename, line_no, opts)
  #     map_file, map_line = LineCache::map_file_line(filename, line_no)
  #     if [filename, line_no] != [map_file, map_line]
  #       loc += " remapped #{canonic_file(map_file)}:#{map_line}"
  #     end
  #   end
  
  #   [loc, line_no, text]
  # end
  
  def format_location(event=@event, frame=@frame, frame_index=@frame_index)
    text      = nil
    ev        = if event.nil? || 0 != frame_index
                  '  ' 
                else
                  (EVENT2ICON[event] || event)
                end
    
    @line_no  = frame.vm_location.line
    
    loc = source_location_info
    loc, @line_no, text = loc_and_text(loc)
    
    "#{ev} (#{loc}"
  end
  
  # FIXME: Use above format_location routine
  def print_location
    text      = nil
    ev        = if @event.nil? || 0 != @frame_index
                  '  ' 
                else
                  (EVENT2ICON[@event] || @event)
                end
    
    @line_no  = @frame.line
    
    loc = source_location_info
    loc, @line_no, text = loc_and_text(loc)
    
    msg "#{ev} (#{loc}"
    
    # if %w(return c-return).member?(@core.event)
    #   retval = Trepan::Frame.value_returned(@frame, @core.event)
    #   msg 'R=> %s' % retval.inspect 
    # end
    
    if text && !text.strip.empty?
      old_maxstring = @settings[:maxstring]
      @settings[:maxstring] = -1
      msg text
      @settings[:maxstring] = old_maxstring
      @line_no -= 1
    end
  end
  
  def source_location_info
    filename  = @frame.file
    canonic_filename = 
      ## if @frame.eval?
      ##  'eval ' + safe_repr(@frame.eval_string.gsub("\n", ';').inspect, 20)
      ## else
      canonic_file(filename, false)
    ## end
    loc = "#{canonic_filename}:#{@frame.line}"
    return loc
  end 
end

if __FILE__ == $0 && caller.size == 0
  # Demo it.
  require_relative './mock'
  dbgr = MockDebugger::MockDebugger.new
  proc = Trepan::CmdProcessor.new([Trepan::UserInterface.new(nil, nil,
                                                            :history_save=>false)])
  proc.settings = {:directory => '$cdir:$cwd'}
  # proc.frame_initialize

  proc.location_initialize
  puts proc.canonic_file(__FILE__)
  proc.settings[:basename] = true
  puts proc.canonic_file(__FILE__)
  puts proc.current_source_text
  # xx = eval <<-END
  #    proc.frame_initialize
  #    ##proc.frame_setup(RubyVM::ThreadFrame.current)
  #    proc.location_initialize
  #    proc.current_source_text
  # END
end