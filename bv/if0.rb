module BV
  class If0 < Expression
    def initialize sexp, context
      @condition = Expression.parse sexp[0], context
      @when_zero = Expression.parse sexp[1], context
      @else = Expression.parse sexp[2], context
    end
    
    def to_sexp
      [:if0, @condition.to_sexp, @when_zero.to_sexp, @else.to_sexp]
    end
    
    def eval context
      if @condition.eval(context) == 0
        @when_zero.eval(context)
      else
        @else.eval(context)
      end
    end
  end
end
