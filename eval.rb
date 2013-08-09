#!/usr/bin/env ruby
$: << '.'

require 'bv'

value = Integer(ARGV.shift) || raise("usage: eval.rb {value} < program")

prg = BV.parse (ARGV.first || STDIN.read)
printf "0x%016x\n" % prg.eval(value)
