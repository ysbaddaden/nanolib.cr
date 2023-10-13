struct Box(T)
  def self.malloc(object : T) : Pointer(Box(T))
    ptr = Pointer(self).malloc(1)
    ptr.value.initialize(object)
    ptr
  end

  def initialize(@object : T)
  end

  def self.unbox(data : Void*) : T
    data.as(Pointer(self)).value.@object
  end
end
