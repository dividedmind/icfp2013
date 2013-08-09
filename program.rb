require 'rspec-expectations'

module BV
  class Program
    def self.parse sexp
      sexp[0].should == :lambda
      x = sexp[1][0]
      @program = Expression.parse sexp[2], x: x
    end
  end
  
  class Expression
    def initialize sexp, context
    end
    
    def self.parse sexp, x: nil, y: nil, z: nil
      context = {x: x, y: y, z: z}
      classes = {
        0 => Zero,
        1 => One,
        x => X,
        y => Y,
        z => Z
      }
      klass = classes[sexp] || BV.const_get(sexp[0].to_s.capitalize.to_sym)
      rest = sexp[1..-1] rescue nil
      klass.new rest, context
    end
  end

  def self.Constant n
    cls = Class.new(Expression) do
      const_set :VALUE, n
    end
  end
  
  Zero = Constant(0)
  One = Constant(1)

  def self.Variable i
    cls = Class.new(Expression) do
      const_set :INDEX, i
    end
  end
  
  X = Variable(:x)
  Y = Variable(:y)
  Z = Variable(:z)
  
  class If0 < Expression
    def initialize sexp, context
      @condition = Expression.parse sexp[0], context
      @when_zero = Expression.parse sexp[1], context
      @else = Expression.parse sexp[2], context
    end
  end
  
  class Fold < Expression
    def initialize sexp, context
      context = context.dup
      @arg = Expression.parse sexp[0], context
      @acc = Expression.parse sexp[1], context
      
      l, p, e = sexp[2]
      l.should == :lambda
      context[:y], context[:z] = p
      @expr = Expression.parse e, context
    end
  end
  
  def self.Op1 op
    cls = Class.new(Expression) do
      const_set :OP, op
      
      def initialize sexp, context
        @arg = Expression.parse sexp[0], context
      end
    end
  end
  
  %w(not shl1 shr1 shr4 shr16).each do |op|
    const_set op.capitalize.to_s, Op1(op)
  end

  def self.Op2 op
    cls = Class.new(Expression) do
      const_set :OP, op
      
      def initialize sexp, context
        @left = Expression.parse sexp[0], context
        @right = Expression.parse sexp[1], context
      end
    end
  end

  And = Op2(:&)
  Or = Op2(:|)
  Xor = Op2(:^)
  Plus = Op2(:+)
end

__END__

load 'program.rb'
require 'sxp'
sexp = SXP.parse "(lambda (x_8067) (if0 (shl1 (and (shl1 1) x_8067)) 0 x_8067))"
p BV::Program::parse sxp
