module BV
  def self.Variable i
    cls = Class.new(Expression) do
      def initialize *_
      end
      
      define_method(:index){ i }
      def to_sexp
        index
      end
      
      def eval context
        context[index]
      end

      def self.generate params
        puts "Generating #{self.name} for params #{params}"
        if params[:size] == 1
          [new]
        else
          []
        end
      end
      
    end
  end
  
  X = Variable(:x)
  Y = Variable(:y)
  Z = Variable(:z)
end
