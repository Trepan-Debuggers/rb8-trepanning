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
      @context.frame_binding(@state.frame_pos)
    end

    def call_string(opts={:maxwidth=>80, :callstyle => :last})
      call_str = ""
      if meth
        locals = local_variables
        if opts[:callstyle] != :short && klass
          if opts[:callstyle] == :tracked
            arg_info = @context.frame_args_info(@state.frame_pos)
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
              call_str[-2..-1] = ",...XX"
              break
            end
          end
          call_str[-2..-1] = ")" # Strip off trailing ', ' if any 
        end
      end
      return call_str
    end

    def describe(opts = {:maxwidth => 80})
      str   = ''
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
      @context.frame_locals(@state.frame_pos)
    end

    def meth
      m = @context.frame_method(@state.frame_pos)
      m ? m.id2name : ''
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
  state = Trepan::State.new(0)
  def foo(a, state)
    x = 1
    context = Debugger.current_context
    frame = Trepan::Frame.new(context, state)
    Debugger.skip do 
      0.upto(Debugger.current_context.stack_size-1) do |i|
        state.frame_pos = i
        puts "Frame #{i}: #{frame.file}, line #{frame.line}, " + 
          "class #{frame.klass}, thread: #{frame.thread}, " + 
          "method: #{frame.meth}"
        p frame.local_variables
        puts frame.describe(:maxwidth => 80, :callstyle=>:tracked)
        puts '-' * 30
      end
    end
  end
  foo('arg', state)
end
