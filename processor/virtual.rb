module Trepan
  class VirtualCmdProcessor
    attr_accessor :interfaces
    attr_accessor :state, :context, :settings
    def initialize(interfaces, settings={})
      @interfaces      = interfaces
      @intf            = interfaces[-1]
      @settings        = settings
    end
    def errmsg(message)
      puts "Error: #{message}"
    end
    def msg(message)
      puts message
    end
    def section(message, opts={})
      puts "Section: #{message}"
    end
  end
end
