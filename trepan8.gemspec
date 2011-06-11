# -*- Ruby -*-
# -*- encoding: utf-8 -*-
require 'rake'
unless Object.const_defined?(:'Trepan')
  if RUBY_VERSION =~ /^1.9.2/
    require File.expand_path(File.dirname(__FILE__) + '/app/options')
  else
    require 'rubygems'; require 'require_relative'
    require_relative './app/options' 
  end
end

Gem::Specification.new do |spec|
  spec.authors      = ['R. Bernstein']
  spec.date         = Time.now
  spec.description = <<-EOF
A modular, testable, Ruby debugger using some of the best ideas from ruby-debug, other debuggers, and Ruby Rails. 

Some of the core debugger concepts have been rethought. As a result, some of this may be experimental.

This version works only with a MRI 1.8 and 1.9.2'

See also rb-trepanning and rbx-trepanning versions that works with Rubinius.
and a patched YARV 1.9.2.
EOF
  # spec.add_dependency('rb-trace', '>= 0.5')

  if RUBY_VERSION.start_with?('1.8')
    spec.add_dependency('linecache', '>= 0.43')
  elsif RUBY_VERSION.start_with?('1.9') 
    spec.add_dependency('linecache19', '>= 0.5.12')
  end

  spec.add_dependency('rbx-require-relative', '> 0.0.4')
  spec.add_dependency('columnize')
  spec.author       = 'R. Bernstein'
  spec.bindir       = 'bin'
  spec.email        = 'rockyb@rubyforge.net'
  spec.executables = ['trepan8']
  spec.files        = `git ls-files`.split("\n")
  spec.has_rdoc     = true
  spec.homepage     = 'http://wiki.github.com/rocky/rb8-trepanning'
  spec.name         = 'trepan8'
  spec.license      = 'MIT'
  if RUBY_VERSION =~ /^1.8.7/
    spec.platform = Gem::Platform::new ['universal', 'ruby', '1.8.7']
  elsif RUBY_VERSION =~ /^1.9.2/
    spec.platform = Gem::Platform::new ['universal', 'ruby', '1.9.2']
  else
    STDERR.puts "Have only tested on MRI 1.8.7 and 1.9.2"
  end
  spec.require_path = 'lib'
  spec.summary      = 'Ruby MRI 1.8.7 and 1.9.2 Trepanning Debugger'
  spec.version      = Trepan::VERSION

  spec.rdoc_options += ['--title', "Trepan #{Trepan::VERSION} Documentation"]

end
