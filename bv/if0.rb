module BV
  class If0 < Expression
    def initialize sexp, context = {}
      if sexp[0].is_a? Expression
        @condition, @when_zero, @else = sexp
      else
        @condition = Expression.parse sexp[0], context
        @when_zero = Expression.parse sexp[1], context
        @else = Expression.parse sexp[2], context
      end
    end
    
    def to_sexp
      @sexp ||= [:if0, @condition.to_sexp, @when_zero.to_sexp, @else.to_sexp]
    end
    
    def operators
      ([:if0] + [@condition, @when_zero, @else].map(&:operators).flatten).sort
    end
    
    def eval context
      if @condition.eval(context) == 0
        @when_zero.eval(context)
      else
        @else.eval(context)
      end
    end
    
    def self.generate(size: size, operators: operators, closed: closed)
      (1..(size - 3)).map do |argsize|
        (1..(size - argsize - 2)).map do |accsize|
          exprsize = size - argsize - accsize - 1
          Expression.generate(size: argsize, operators: operators, closed: closed).flatten.map do |arg|
            Expression.generate(size: accsize, operators: operators, closed: closed).flatten.map do |acc|
              Expression.generate(size: exprsize, operators: operators, closed: closed).flatten.map do |expr|
                new [arg, acc, expr]
              end
            end
          end
        end
      end.flatten
    end

  end
end
