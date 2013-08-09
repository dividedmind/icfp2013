module BV
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
    
    def eval value
      @program.eval x: value
    end
  end
end
