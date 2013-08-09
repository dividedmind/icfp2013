module BV
  def self.Op2 op
    cls = Class.new(Expression) do
      define_method(:op){ op }
      
      def initialize sexp, context
        @left = Expression.parse sexp[0], context
        @right = Expression.parse sexp[1], context
      end
      
      def to_sexp
        [op, @left.to_sexp, @right.to_sexp]
      end
      
      def eval context
        @left.eval(context).send op, @right.eval(context)
      end
    end
  end

  %w(and or xor plus).each do |op|
    const_set op.capitalize.to_s, Op2(op.to_sym)
  end
end
