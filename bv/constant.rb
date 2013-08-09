module BV
  def self.Constant n
    cls = Class.new(Expression) do
      define_method(:value){ n }
      def to_sexp
        value
      end
      
      def eval _
        value
      end
    end
  end
  
  Zero = Constant(0)
  One = Constant(1)
end
