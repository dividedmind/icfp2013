#!/usr/bin/env ruby
$: << '.'

require 'bv'

require 'json'

problem = JSON.parse ARGF.read

puts BV.generate(size: problem['size'], operators: problem['operators']).map(&:to_s).join("\n")
