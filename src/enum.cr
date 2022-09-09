struct Enum
  def ==(other : self) : Bool
    value == other.value
  end

  def ===(other : self) : Bool
    value == other.value
  end

  def |(other : self) : self
    self.class.new(value | other.value)
  end

  def &(other : self) : self
    self.class.new(value & other.value)
  end

  def ^(other : self) : self
    self.class.new(value ^ other.value)
  end
end
