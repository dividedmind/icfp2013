class Integer
  def bytes
    [self].pack('Q<').unpack('C*')
  end
  
  BV_MAX = (1 << 64) - 1
  
  def not
    BV_MAX ^ self
  end
  
  def shl1
    (self << 1) & BV_MAX
  end

  def shr1
    self >> 1
  end
  
  def shr4
    self >> 4
  end
  
  def shr16
    self >> 16
  end
  
  def and other
    self & other
  end
  
  def or other
    self | other
  end
  
  def xor other
    self ^ other
  end

  def plus other
    (self + other) & BV_MAX
  end
end
