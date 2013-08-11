module BV
  class Op2 < Expression
    def initialize sexp, context = {}
      if sexp[0].is_a? Expression
        @left, @right = sexp
      else
        @left = Expression.parse sexp[0], context
        @right = Expression.parse sexp[1], context
      end
    end
    
    def to_sexp
      @sexp ||= [op, @left.to_sexp, @right.to_sexp]
    end
    
    def eval context
      @left.eval(context).send op, @right.eval(context)
    end
    
    def operators
      ([op] + @left.operators + @right.operators).sort
    end
  
    OPS = [:and, :or, :xor, :plus]
    def self.generate(size: size, operators: operators, closed: closed)
      # STDERR.puts "Generating #{self.name} for size #{size} and ops #{operators.inspect}"
      size -= 1
      (1..(size / 2)).map do |lsize|
        if lsize * 2 != size
          lefts = Expression.generate(size: lsize, operators: operators, closed: closed).flatten
          rights = Expression.generate(size: (size - lsize), operators: operators, closed: closed).flatten
          lefts.map do |left|
            rights.map do |right|
              new [left, right]
            end
          end
        else
          Expression.generate(size: lsize, operators: operators, closed: closed).flatten.repeated_combination(2).map do |l|
            new l
          end
        end
      end.flatten
    end
  end
  
  def self.Op2 op
    Class.new(Op2) do
      define_method(:op){ op }
    end
  end

  Op2::OPS.each do |op|
    const_set op.to_s.capitalize, Op2(op.to_sym)
  end
end
