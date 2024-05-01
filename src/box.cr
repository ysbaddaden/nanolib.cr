# Wraps a type so it can be passed around as a `Pointer(Void)`.
#
# Warning: while stdlib's Box is a class and allocated in the HEAP, nano's Box
# is a struct and thus allocated on the stack by default.
#
# For most types you shouldn't need `Box` as you'll be working with pointers
# directly or variables for which you can get a pointer, but for some types, for
# example procs, a `Box` may be useful.
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
