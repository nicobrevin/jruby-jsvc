#! /usr/bin/env ruby

require 'jsvc'
JSVC.init

require 'jsvc/initd_cli'

JSVC::InitdCLI.new.run(ARGV)
