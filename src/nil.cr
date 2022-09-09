struct Nil
  def object_id
    0_u64
  end

  def ==(other : self)
    true
  end

  def ==(other)
    false
  end

  def try(&block) : self
    self
  end

  # def not_nil! : NoReturn
  #   panic! "nil assertion error"
  # end
end
