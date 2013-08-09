module BV
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
    
    def eval context
      @arg.eval(context).bytes.inject(@acc.eval context) { |acc, byte| @expr.eval context.merge(y: byte, z: acc) }
    end
  end
end
