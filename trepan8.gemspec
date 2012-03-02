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

A modular, testable, Ruby debugger using some of the best ideas from
ruby-debug, other debuggers, and Ruby Rails.

Some of the core debugger concepts have been rethought. As a result,
some of this may be experimental.

This version works only with MRI 1.8 and 1.9'

See rbx-trepanning for a version that works with Rubinius, and trepanning
and for something that works with a patched YARV 1.9.2.
EOF
  # spec.add_dependency('rb-trace', '>= 0.5')

  spec.add_dependency('rbx-require-relative', '> 0.0.4')
  spec.add_dependency('rdoc', '> 2.4.2')
  spec.add_dependency('columnize')
  spec.author       = 'R. Bernstein'
  spec.bindir       = 'bin'
  spec.email        = 'rockyb@rubyforge.net'
  spec.executables = ['trepan8']
  spec.files        = `git ls-files`.split("\n")
  spec.has_rdoc     = true
  spec.homepage     = 'http://wiki.github.com/rocky/rb8-trepanning'
  spec.name         = 'rb8-trepanning'
  spec.license      = 'MIT'
  spec.platform     = Gem::Platform::RUBY
  spec.require_path = 'lib'
  spec.summary      = 'Ruby Trepanning Debugger using ruby-debug-base'
  spec.version      = Trepan::VERSION

  spec.rdoc_options += ['--title', "Trepan #{Trepan::VERSION} Documentation"]

end
