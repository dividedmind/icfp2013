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
              if left.class.name == "BV::Zero" and ["BV::Plus", "BV::Or", "BV::Xor"].include?(self.name)
                right
              elsif left.class.name == "BV::Zero" and ["BV::And"].include?(self.name)
                # puts 'ERASING'
                left
              elsif right.class.name == "BV::Zero" and ["BV::Plus", "BV::Or", "BV::Xor"].include?(self.name)
                left
              elsif right.class.name == "BV::Zero" and ["BV::And"].include?(self.name)
                right
              elsif left == right and ["BV::Plus"].include?(self.name) and operators.include?(:shl1)
                BV::Shr1.new(left)
              elsif left == right and ["BV::And", "BV::Or"].include?(self.name)
                left
              elsif left == right and ["BV::Xor"].include?(self.name)
                BV::Zero.new()
              elsif (left.class.name == "BV::Not" and left.arg == right) or (right.class.name == "BV::Not" and right.arg == left)
                if ["BV::Or", "BV::Xor", "BV::Plus"].include?(self.name)
                  BV::Not.new(BV::Zero.new())
                elsif self.name == "BV::And"
                  BV::Zero.new()
                else
                  p "WTF"
                  new [left, right]
                end
              elsif left.class.name == "BV::Not" and left.arg.class.name == "BV::Zero"
                if self.name == "BV::And"
                  right
                elsif self.name == "BV::Or"
                  left
                elsif self.name == "BV::Xor"
                  BV::Not.new(right)
                else
                  new [left,right]
                end
              elsif right.class.name == "BV::Not" and right.arg.class.name == "BV::Zero"
                if self.name == "BV::And"
                  left
                elsif self.name == "BV::Or"
                  right
                elsif self.name == "BV::Xor"
                  BV::Not.new(left)
                else
                  new [left, right]
                end
              else
                new [left, right]
              end
            end
          end
        else
          Expression.generate(size: lsize, operators: operators, closed: closed).flatten.repeated_combination(2).map do |l|
            left, right = l
            if left.class.name == "BV::Zero" and ["BV::Plus", "BV::Or", "BV::Xor"].include?(self.name)
              right
            elsif left.class.name == "BV::Zero" and ["BV::And"].include?(self.name)
              left
            elsif right.class.name == "BV::Zero" and ["BV::Plus", "BV::Or", "BV::Xor"].include?(self.name)
              left
            elsif right.class.name == "BV::Zero" and ["BV::And"].include?(self.name)
              right
            elsif left == right and ["BV::Plus"].include?(self.name) and operators.include?(:shl1)
              BV::Shr1.new(left)
            elsif left == right and ["BV::And", "BV::Or"].include?(self.name)
              left
            elsif left == right and ["BV::Xor"].include?(self.name)
              BV::Zero.new()
            elsif (left.class.name == "BV::Not" and left.arg == right) or (right.class.name == "BV::Not" and right.arg == left)
              if ["BV::Or", "BV::Xor", "BV::Plus"].include?(self.name)
                BV::Not.new(BV::Zero.new())
              elsif self.name == "BV::And"
                BV::Zero.new()
              else
                p "WTF"
                new [left, right]
              end
            elsif left.class.name == "BV::Not" and left.arg.class.name == "BV::Zero"
              if self.name == "BV::And"
                right
              elsif self.name == "BV::Or"
                left
              elsif self.name == "BV::Xor"
                BV::Not.new(right)
              else
                new l
              end
            elsif right.class.name == "BV::Not" and right.arg.class.name == "BV::Zero"
              if self.name == "BV::And"
                left
              elsif self.name == "BV::Or"
                right
              elsif self.name == "BV::Xor"
                BV::Not.new(left)
              else
                new l
              end
            else
              new l
            end
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
