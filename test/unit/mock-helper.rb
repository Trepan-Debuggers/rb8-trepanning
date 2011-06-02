require 'test/unit'
require 'rubygems'; require 'require_relative'
require 'ruby-debug-base'
require_relative '../../processor/mock'

module MockUnitHelper
  def common_setup(name)
    Debugger.start unless Debugger.started?
    @dbg, @cmd = MockDebugger::setup(name, false)
  end
end

