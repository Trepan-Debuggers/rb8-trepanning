module Trepan
  class InterruptCommand < OldCommand # :nodoc:
    self.allow_in_control     = true
    self.allow_in_post_mortem = false
    self.event                = false
    self.need_context         = true
    
    def regexp
      /^\s*i(?:nterrupt)?\s*$/
    end
    
    def execute
      unless Debugger.interrupt_last
        context = Debugger.thread_context(Thread.main)
        context.interrupt
      end
    end
    
    class << self
      def help_command
        'interrupt'
      end
      
      def help(cmd)
        %{
          i[nterrupt]\tinterrupt the program
        }
      end
    end
  end
end
