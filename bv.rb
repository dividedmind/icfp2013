require 'sxp'
require 'rspec-expectations'

require 'bv/program'
require 'bv/expression'
require 'bv/constant'
require 'bv/variable'
require 'bv/if0'
require 'bv/fold'
require 'bv/op1'
require 'bv/op2'
require 'bv/number'

module BV
  def self.parse input
    Program.new SXP.parse(input)
  end
end

__END__

$: << '.'
require 'bv'
prg = BV.parse "(lambda (x_3597) (fold x_3597 0 (lambda (x_3597 x_3598) (and (shr4 x_3597) x_3597))))"
puts prg.to_s
