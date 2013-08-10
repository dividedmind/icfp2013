module BV
  class Program
    def initialize exp
      if exp.is_a? Expression
        @program = exp
      else
        sexp[0].should == :lambda
        x = sexp[1][0]
        @program = Expression.parse sexp[2], x: x
      end
    end
    
    attr_accessor :program
    
    def to_sexp
      @sexp ||= [:lambda, [:x], @program.to_sexp]
    end
    
    def to_s
      sio = StringIO.new
      gen = SXP::Generator.new sio
      gen.render to_sexp
      sio.string.strip
    end
    
    def eval value
      @program.eval x: value
    end
    
    def self.generate(size: size, operators: operators)
      operators -= [:bonus]
      operators = operators.sort.map &:to_sym
      tfold = false
      if operators.include? :tfold
        operators -= [:tfold]
        size -= 4
        tfold = :tfold
      end
      exprs = Expression.generate(size: size - 1, operators: operators.sort, closed: tfold).flatten.find_all {|e|e.operators.uniq == operators.uniq }.uniq
      if tfold
        exprs = exprs.map do |expr|
          Fold.new [X.new, Zero.new, expr]
        end
      end
      
      exprs.reject!{|e| !e.has_x }
      
      exprs.map {|e| Program.new e}
    end
  end
end
