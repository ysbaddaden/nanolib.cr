struct Proc
  def self.new(pointer : Void*, closure_data : Void*)
    func = {pointer, closure_data}
    ptr = pointerof(func).as(self*)
    ptr.value
  end

  def pointer : Void*
    internal_representation[0]
  end

  def closure_data : Void*
    internal_representation[1]
  end

  private def internal_representation
    func = self
    ptr = pointerof(func).as({Void*, Void*}*)
    ptr.value
  end
end
