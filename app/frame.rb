# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
module Trepan

  # Call-Stack frame methods
  class Frame
    attr_accessor :stack_size, :index
    def initialize(context, index=0)
      @context = context
      @index = index
      @stack_size = @context.stack_size
      reset
    end

    def reset
      @binding = @klass = @file = @line = 
        @local_variables = @method_name = @thread = nil
    end

    def index=(new_value)
      if new_value > 0 && new_value < @stack_size
        reset
        @index  = new_value
      else
        nil
      end
    end

    def run(code, filename=nil)
      filename='(eval :%s)' % code unless filename
      eval(code, self.binding, filename)
    end

    def binding
      @binding ||= @context.frame_binding(@index)
    end

    def call_string(opts={:maxwidth=>80, :callstyle => :last})
      call_str = ""
      if method_name
        locals = local_variables
        if opts[:callstyle] != :short && klass
          if opts[:callstyle] == :tracked
            arg_info = @context.frame_args_info(@index)
          end
          call_str << "#{klass}." 
        end
        call_str << method_name
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
      str       = ''
      # FIXME There seem to be bugs in showing call if
      # index != 0
      call_str  = index == 0 ? call_string(opts) : ''
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
      @args ||= @context.frame_args(@index)
    end

    def file
      @file ||= @context.frame_file(@index)
    end

    def klass
      @klass ||= @context.frame_class(@index)
    end

    def line
      @line ||= @context.frame_line(@index)
    end

    def local_variables
      @local_variables ||= @context.frame_locals(@index)
    end

    def method_name
      if @method_name
        @method_name
      else
        m = @context.frame_method(@index)
        @method_name = m ? m.id2name : ''
      end
    end

    def thread
      @thread ||= @context.thread
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
  require 'rubygems'
  require 'ruby-debug-base'; Debugger.start
  def foo(str, num)
    x = 1
    context = Debugger.current_context
    Debugger.skip do 
      0.upto(Debugger.current_context.stack_size-1) do |i|
        frame = Trepan::Frame.new(context)
        frame.index = i
        puts "Frame #{i}: #{frame.file}, line #{frame.line}, " + 
          "class #{frame.klass}, thread: #{frame.thread}, " + 
          "method: #{frame.method_name}"
        p frame.local_variables
        puts frame.describe(:maxwidth => 80, :callstyle=>:tracked)
        puts '-' * 30
      end
    end
  end
  foo('arg', 5)
end
