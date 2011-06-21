# Module/Package to do the most-common thing: get into the debugger with 
# minimal fuss. Compare with: require "debug"
require 'rubygems'
require 'require_relative'
require './trepanning'
Trepan.start
debugger
