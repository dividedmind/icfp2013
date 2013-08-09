module BV
  class Fold < Expression
    def initialize sexp, context = {x: :x, y: :y, z: :z}
      if sexp[0].is_a? Expression
        @arg, @acc, @expr = sexp
      else
        context = context.dup
        @arg = Expression.parse sexp[0], context
        @acc = Expression.parse sexp[1], context
        
        l, p, e = sexp[2]
        l.should == :lambda
        context[:y], context[:z] = p
        @expr = Expression.parse e, context
      end
    end
    
    def operators
      ([:fold] + [@arg, @acc, @expr].map(&:operators).flatten).sort
    end

    def to_sexp
      [:fold, @arg.to_sexp, @acc.to_sexp, [:lambda, [:y, :z], @expr.to_sexp]]
    end
    
    def eval context
      @arg.eval(context).bytes.inject(@acc.eval context) { |acc, byte| @expr.eval context.merge(y: byte, z: acc) }
    end
    
    def self.generate size: size, operators: operators, closed: false
      operators = operators - [:fold]
      (1..(size - 3)).map do |argsize|
        (1..(size - argsize - 2)).map do |accsize|
          exprsize = size - argsize - accsize - 1
          Expression.generate(size: argsize, operators: operators).flatten.map do |arg|
            Expression.generate(size: accsize, operators: operators).flatten.map do |acc|
              Expression.generate(size: exprsize, operators: operators, closed: true).flatten.map do |expr|
                new arg, acc, expr
              end
            end
          end
        end
      end.flatten
    end
  end
end
