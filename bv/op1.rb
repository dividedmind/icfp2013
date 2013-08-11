module BV
  class Op1 < Expression
    def initialize sexp, context = {}
      p sexp
      sexp = Expression.parse sexp[0], context unless sexp.is_a?(Expression)
      @arg = sexp
    end
    
    def to_sexp
      @sexp ||= [op, @arg.to_sexp]
    end
    
    def eval context
      @arg.eval(context).send op
    end

    OPS = [:not, :shl1, :shr1, :shr4, :shr16]
    def operators
      ([op] + @arg.operators).sort
    end
    
    def self.generate params
      # STDERR.puts "Generating #{self.name} for params #{params}"
      Expression.generate(params.merge size: (params[:size] - 1)).flatten.map do |e|
        new e
      end
    end

  end
  
  def self.Op1 op
    cls = Class.new(Op1) do
      define_method(:op){ op }
    end
  end
  
  Op1::OPS.each do |op|
    const_set op.to_s.capitalize, Op1(op.to_sym)
  end
end
