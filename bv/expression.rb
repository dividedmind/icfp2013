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
  end
end