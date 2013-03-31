# Copyright (C) 2010-2011, 2013 Rocky Bernstein <rockyb@rubyforge.net>
require 'rubygems';
begin
  require 'linecache'
rescue LoadError
  require 'linecache19'
end
require 'require_relative'
# require_relative 'disassemble'
require_relative 'msg'
# require_relative 'frame'
# require_relative '../app/file'
require_relative 'virtual'
class Trepan::CmdProcessor < Trepan::VirtualCmdProcessor

    unless defined?(EVENT2ICON)
      # Event icons used in printing locations.
      EVENT2ICON = {
        'breakpoint'     => 'xx',
        'tbrkpt'         => 'x1',
        'c-call'         => 'C>',
        'c-return'       => '<C',
        'step-call'      => '->',
        'call'           => '->',
        'catchpoint'     => '!!',
        'class'          => '::',
        'coverage'       => '[]',
        'debugger-call'  => ':o',
        'end'            => '-|',
        'line'           => '--',
        'step'           => '--',
        'post-mortem'    => ':/',
        'raise'          => '!!',
        'return'         => '<-',
        'start'          => '>>',
        'switch'         => 'sw',
        'trace-var'      => '$V',
        'unknown'        => '?!',
        'vm'             => 'VM',
        'vm-insn'        => '..',
      }
    end

  def canonic_file(filename, resolve=true)
    # For now we want resolved filenames
    if @settings[:basename]
      return File.basename(filename)
    end
    if resolve
      filename = LineCache::unmap_file(filename)
      if !File.exist?(filename)
        if (try_filename = resolve_file_with_dir(filename))
          filename = try_filename if File.exist?(filename)
        end
      end
    end
    File.expand_path(filename)
  end

  # Return the text to the current source line.
  def current_source_text
    LineCache::getline(@frame.file, @frame.line).chomp
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
                :reload_on_change => @settings[:reload],
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

  def loc_and_text(opts=
                   {:reload_on_change => @settings[:reload],
                     :output => @settings[:highlight]
                   })

    loc = source_location_info
    line_no  = @frame.line
    filename = @frame.file

#    if @frame.eval?
#      file = LineCache::map_script(static.script)
#      text = LineCache::getline(static.script, line_no, opts)
#      loc += " remapped #{canonic_file(file)}:#{line_no}"
#    else
      text = line_at(filename, line_no, opts)
      map_file, map_line = LineCache::unmap_file_line(filename, line_no)
      if [filename, line_no] != [map_file, map_line]
        loc += " remapped #{canonic_file(map_file)}:#{map_line}"
      end
#    end
    [loc, line_no, text]
  end

  def format_location(event=@event, frame=@frame, frame_index=@frame.index)
    text      = nil
    ev        = if event.nil? || 0 != frame_index
                  '  '
                else
                  (EVENT2ICON[event] || event)
                end

    @line_no  = frame.line
    loc, @line_no, text = loc_and_text

    "#{ev} (#{loc}"
  end

  # FIXME: Use above format_location routine
  def print_location
    text      = nil
    ev        = if @event.nil? || 0 != @frame.index
                  '  '
                else
                  (EVENT2ICON[@event] || @event)
                end

    @line_no  = @frame.line
    loc, @line_no, text = loc_and_text

    msg "#{ev} (#{loc})"

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
  proc.frame_initialize
  require 'ruby-debug'; Debugger.start
  proc.frame_setup(Debugger.current_context, nil)
  puts proc.canonic_file(__FILE__)
  proc.settings[:basename] = true
  puts proc.canonic_file(__FILE__)
  puts proc.current_source_text
  xx = eval <<-END
     proc.frame_initialize
     proc.frame_setup(Debugger.current_context, nil)
     puts proc.current_source_text
  END
  Debugger.stop
end
