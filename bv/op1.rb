module BV
  class Op1 < Expression
    def initialize sexp, context = {}
      sexp = Expression.parse sexp[0], context unless sexp.is_a?(Expression)
      @arg = sexp
    end
    
    def to_sexp
      @sexp ||= [op, @arg.to_sexp]
    end
    
    def arg
      @arg
    end

    def eval context
      @arg.eval(context).send op
    end

    OPS = [:not, :shl1, :shr1, :shr4, :shr16]
    def operators
      ([op] + @arg.operators).sort
    end
    
    def self.generate params
      if self.name == "BV::Shr4"
        params[:operators] = params[:operators] - [:shr1]
      end

      if self.name == "BV:Shr16"
        params[:operators] = params[:operators] - [:shr4,:shr1]
      end

      # STDERR.puts "Generating #{self.name} for params #{params}"
      Expression.generate(params.merge size: (params[:size] - 1)).flatten.map do |e|
        if e.class.name == "BV::Zero" and self.name != "BV::Not"
          e
        elsif e.class.name == "BV::One" and self.name == "BV::Shl1"
          BV::Zero.new()
        elsif e.class.name == "BV::Not" and self.name == "BV::Not"
          e.arg
        else
          new e
        end
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
