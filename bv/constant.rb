module BV
  def self.Constant n
    cls = Class.new(Expression) do
      def initialize *a
      end
      
      define_method(:value){ n }
      def to_sexp
        @sexp ||= value
      end
      
      def eval _
        value
      end
      
      def self.generate(size: size, **_)
        if size == 1
          [new]
        else
          []
        end
      end
    end
  end
  
  Zero = Constant(0)
  One = Constant(1)
end
