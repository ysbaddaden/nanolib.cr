struct Nil
  @[AlwaysInline]
  def object_id : UInt64
    0_u64
  end

  @[AlwaysInline]
  def ==(other : self) : Bool
    true
  end

  @[AlwaysInline]
  def ==(other) : Bool
    false
  end

  @[AlwaysInline]
  def try(&block) : self
    self
  end

  @[AlwaysInline]
  def not_nil!(message : String? = nil) : NoReturn
    panic! message || "nil assertion error"
  end
end
