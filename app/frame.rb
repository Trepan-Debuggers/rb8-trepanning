# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
module Trepan

  # Call-Stack frame methods
  class Frame
    def initialize(context, state)
      @context = context
      @state = state
    end

    def run(code, filename=nil)
      filename="(eval :%s)" % code unless filename
      eval(code, self.binding, filename)
    end

    def binding
      @binding ||= @context.frame_binding(@state.frame_pos)
    end

    # def describe(opts = {})
    #   if method.required_args > 0
    #     locals = []
    #     0.upto(method.required_args-1) do |arg|
    #       locals << method.local_names[arg].to_s
    #     end

    #     arg_str = locals.join(", ")
    #   else
    #     arg_str = ""
    #   end

    #   loc = @vm_location

    #   if loc.is_block
    #     if arg_str.empty?
    #       recv = "{ } in #{loc.describe_receiver}#{loc.name}"
    #     else
    #       recv = "{|#{arg_str}| } in #{loc.describe_receiver}#{loc.name}"
    #     end
    #   else
    #     if arg_str.empty?
    #       recv = loc.describe
    #     else
    #       recv = "#{loc.describe}(#{arg_str})"
    #     end
    #   end

    #   filename = loc.method.active_path
    #   filename = File.basename(filename) if opts[:basename]
    #   str = "#{recv} at #{filename}:#{loc.line}"
    #   if opts[:show_ip]
    #     str << " (@#{loc.ip})"
    #   end

    #   str
    # end

    def args
      @context.frame_args(@state.frame_pos)
    end

    def file
      @context.frame_file(@state.frame_pos)
    end

    def line
      @context.frame_line(@state.frame_pos)
    end

    def local_variables
      @context.frame_locals
    end

    def method
      @context.frame_method(@state.frame_pos)
    end

    def stack_size
      @context.stack_size
    end

    # def scope
    #   @vm_location.variables
    # end

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
      puts "Frame #{i}"
      p frame.file
      p frame.line
      p frame.local_variables
    end
  end
  state.frame_pos = 2
  foo(1, state)
end
