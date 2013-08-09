module BV
  class Op1 < Expression
    def initialize sexp, context
      @arg = Expression.parse sexp[0], context
    end
    
    def to_sexp
      [op, @arg.to_sexp]
    end
    
    def eval context
      @arg.eval(context).send op
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
end
