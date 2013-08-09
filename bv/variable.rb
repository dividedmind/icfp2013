module BV
  def self.Variable i
    cls = Class.new(Expression) do
      define_method(:index){ i }
      def to_sexp
        index
      end
      
      def eval context
        context[index]
      end
    end
  end
  
  X = Variable(:x)
  Y = Variable(:y)
  Z = Variable(:z)
end
