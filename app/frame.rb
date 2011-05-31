# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
module Trepan

  # Call-Stack frame methods
  class Frame
    def initialize(context, state)
      @context = context
      @state = state
    end

    def run(code, filename=nil)
      filename='(eval :%s)' % code unless filename
      eval(code, self.binding, filename)
    end

    def binding
      @binding ||= @context.frame_binding(@state.frame_pos)
    end

    def call_string(opts={:maxwidth=>80})
      call_str = ""
      klass = self.klass
      if meth
        args = self.args
        locals = local_variables
        if opts[:callstyle] != :short && klass
          if opts[:callstyle] == :tracked
            arg_info = context.frame_args_info(pos)
          end
          call_str << "#{klass}." 
        end
        call_str << meth
        if args.any?
          call_str << "("
          args.each_with_index do |name, i|
            case opts[:callstyle] 
            when :short
              call_str += "%s, " % [name]
            when :last
              klass = locals[name].class
              if klass.inspect.size > 20+3
                klass = klass.inspect[0..20]+"..." 
              end
              call_str += "%s#%s, " % [name, klass]
            when :tracked
              if arg_info && arg_info.size > i
                call_str += "#{name}: #{arg_info[i].inspect}, "
              else
                call_str += "%s, " % name
              end
            end
            if call_str.size > opts[:maxwidth]
              # Strip off trailing ', ' if any but add stuff for later trunc
              call_str[-2..-1] = ",..."
              break
            end
          end
          call_str[-1..-1] = '' if call_str[-1..-1] == ','
          call_str += ')'
        end
      end
      return call_str
    end

    def describe(opts = {:maxwidth => 80})
      str   = ''
      file  = self.file
      line  = self.line
      klass = self.klass
      unless opts[:full_path]
        path_components = file.split(/[\\\/]/)
        if path_components.size > 3
          path_components[0...-3] = '...'
          file = path_components.join(File::ALT_SEPARATOR || File::SEPARATOR)
        end
      end
      
      call_str  = call_string(opts)
      file_line = "at line %s:%d\n" % [file, line]
      unless call_str.empty?
        str += call_str + ' '
        if str.size + call_str.size + 1 + file_line.size > opts[:maxwidth]
          str += "\n       "
        else
          str += '  '
        end
      end
      str += file_line
      str
    end

    def args
      @context.frame_args(@state.frame_pos)
    end

    def file
      @context.frame_file(@state.frame_pos)
    end

    def klass
      @context.frame_class(@state.frame_pos)
    end

    def line
      @context.frame_line(@state.frame_pos)
    end

    def local_variables
      @context.frame_locals
    end

    def meth
      @context.frame_method(@state.frame_pos).id2name
    end

    def stack_size
      @context.stack_size
    end

    def thread
      @context.thread
    end

    # def eval?
    #   static = @vm_location.static_scope
    #   static && static.script && static.script.eval_source
    # end

    # def eval_string
    #   return nil unless eval?
    #   static = @vm_location.static_scope
    #   static.script.eval_source
    # end

  end
end

if __FILE__ == $0
  # Show it:
  class Trepan::State
    attr_accessor :frame_pos
    def initialize(frame_pos=0)
      @frame_pos = frame_pos
    end
  end
  require 'rubygems'
  require 'ruby-debug-base'; Debugger.start
  state = Trepan::State.new(1)
  context = Debugger.current_context
  frame = Trepan::Frame.new(context, state)
  p frame.file
  p frame.line
  p frame.local_variables
  def foo(a, state)
    x = 1
    context = Debugger.current_context
    0.upto(context.stack_size) do |i|
      state.frame_pos = i
      frame = Trepan::Frame.new(context, state)
      puts "Frame #{i}: #{frame.file}, line #{frame.line}, class #{frame.klass}, thread: #{frame.thread}, " + 
        "method: #{frame.meth}"
      p frame.local_variables
      puts frame.describe
      puts '-' * 30
    end
  end
  foo('arg', state)
end
