class Object
  def ===(other)
    self == other
  end

  def unsafe_as(type : T.class) forall T
    x = self
    pointerof(x).as(T*).value
  end

  def tap(&block) : self
    yield self
    self
  end

  def try(&block)
    yield self
  end

  # def not_nil! : self
  #   self
  # end
end
