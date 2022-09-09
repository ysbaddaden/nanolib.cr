# FIXME: stdlib's Box is a class and allocated in the HEAP
struct Box(T)
  def initialize(@object : T)
  end

  def self.unbox(data : Void*) : T
    data.as(Pointer(self)).value.@object
  end
end
