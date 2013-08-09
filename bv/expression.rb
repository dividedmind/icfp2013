module BV
  class Expression
    def initialize sexp, context
    end
    
    def self.parse sexp, x: nil, y: nil, z: nil
      context = {x: x, y: y, z: z}
      classes = {
        0 => Zero,
        1 => One,
        x => X,
        y => Y,
        z => Z
      }
      klass = classes[sexp] || BV.const_get(sexp[0].to_s.capitalize.to_sym)
      rest = sexp[1..-1] rescue nil
      klass.new rest, context
    end
    
    def operators
      []
    end
  
    def self.generate size: size, operators: operators, closed: false
      STDERR.puts "Generating #{self.name} for size #{size} and ops #{operators.inspect}"
      classes = []
      if size == 1
        classes += %i(zero one)
        classes += %i(y z) if closed
        classes += %i(x) unless closed == :tfold
      else
        classes += Op1::OPS & operators if size > 1
        classes += Op2::OPS & operators if size > 2
        classes += [:if0] if size > 3 && (operators.include? :if0)
        classes += [:fold] if size > 4 && !closed && (operators.include? :fold)
      end
      
      classes.map {|x| BV::const_get(x.capitalize).generate size: size, operators: operators, closed: closed }.flatten
    end
  end
end
