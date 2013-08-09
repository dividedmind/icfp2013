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
      [:lambda, [:x], @program.to_sexp]
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
    
    def self.generate size: size, operators: operators
      operators = operators.sort.map &:to_sym
      Expression.generate(size: size - 1, operators: operators.sort).flatten.
        find_all {|e|e.operators == operators }.
        map {|e| Program.new e}
    end
  end
end
