require 'rspec-expectations'
require 'sxp'

module BV
  def self.parse input
    Program.new SXP.parse(input)
  end
  
  class Program
    def initialize sexp
      sexp[0].should == :lambda
      x = sexp[1][0]
      @program = Expression.parse sexp[2], x: x
    end
    
    def to_sexp
      [:lambda, [:x], @program.to_sexp]
    end
    
    def to_s
      sio = StringIO.new
      gen = SXP::Generator.new sio
      gen.render to_sexp
      sio.string.strip
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
      define_method(:value){ n }
      def to_sexp
        value
      end
    end
  end
  
  Zero = Constant(0)
  One = Constant(1)

  def self.Variable i
    cls = Class.new(Expression) do
      define_method(:index){ i }
      def to_sexp
        index
      end
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
    
    def to_sexp
      [:if0, @condition.to_sexp, @when_zero.to_sexp, @else.to_sexp]
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

    def to_sexp
      [:fold, @arg.to_sexp, @acc.to_sexp, [:lambda, [:y, :z], @expr.to_sexp]]
    end
  end
  
  class Op1 < Expression
    def initialize sexp, context
      @arg = Expression.parse sexp[0], context
    end
    
    def to_sexp
      [op, @arg.to_sexp]
    end
  end
  
  def self.Op1 op
    cls = Class.new(Op1) do
      define_method(:op){ op }
    end
  end
  
  %w(not shl1 shr1 shr4 shr16).each do |op|
    const_set op.capitalize.to_s, Op1(op.to_sym)
  end

  def self.Op2 op
    cls = Class.new(Expression) do
      define_method(:op){ op }
      
      def initialize sexp, context
        @left = Expression.parse sexp[0], context
        @right = Expression.parse sexp[1], context
      end
      
      def to_sexp
        [op, @left.to_sexp, @right.to_sexp]
      end
    end
  end

  %w(and or xor plus).each do |op|
    const_set op.capitalize.to_s, Op2(op.to_sym)
  end
end

__END__

load 'program.rb'
require 'sxp'
prg = BV.parse "(lambda (x_3597) (fold x_3597 0 (lambda (x_3597 x_3598) (and (shr4 x_3597) x_3597))))"
puts prg.to_s
