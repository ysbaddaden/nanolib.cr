struct Number
  alias Primitive = Int::Primitive | Float::Primitive

  def self.zero : self
    new(0)
  end

  def +
    self
  end

  def <=>(other : self) : Int32
    self > other ? 1 : (self < other ? -1 : 0)
  end

  def %(other : self) : self
    modulo(other)
  end
end
