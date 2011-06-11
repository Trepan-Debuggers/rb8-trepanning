# -*- Ruby -*-
# -*- encoding: utf-8 -*-
require 'rake'
require 'rubygems'; require 'require_relative'
require_relative './app/options' unless 
  Object.const_defined?(:'Trepan')

Gem::Specification.new do |spec|
  spec.authors      = ['R. Bernstein']
  spec.date         = Time.now
  spec.description = <<-EOF
A modular, testable, Ruby debugger using some of the best ideas from ruby-debug, other debuggers, and Ruby Rails. 

Some of the core debugger concepts have been rethought. As a result, some of this may be experimental.

This version works only with a MRI 1.8'

See also rb-trepanning and rbx-trepanning versions that works with Rubinius.
and a patched YARV 1.9.2.
EOF
  # spec.add_dependency('rb-trace', '>= 0.5')
  spec.add_dependency('linecache', '>= 0.43')
  spec.add_dependency('rbx-require-relative', '> 0.0.4')
  spec.add_dependency('columnize')
  spec.add_dependency('diff-lcs') # For testing only
  spec.author       = 'R. Bernstein'
  spec.bindir       = 'bin'
  spec.email        = 'rockyb@rubyforge.net'
  spec.executables = ['trepan8']
  spec.files        = `git ls-files`.split("\n")
  spec.has_rdoc     = true
  spec.homepage     = 'http://wiki.github.com/rocky/rb8-trepanning'
  spec.name         = 'trepan8'
  spec.license      = 'MIT'
  spec.platform     = Gem::Platform::RUBY
  spec.require_path = 'lib'
  spec.summary      = 'Ruby 1.8.7 Trepanning Debugger'
  spec.version      = Trepan::VERSION

  # Make the readme file the start page for the generated html
  spec.rdoc_options += ['--title', "Trepan #{Trepan::VERSION} Documentation"]

end
