lib LibC
  fun strncmp(Char*, Char*, SizeT) : Int
end

class String
  @[AlwaysInline]
  def to_unsafe : UInt8*
    pointerof(@c)
  end

  @[AlwaysInline]
  def bytesize : Int32
    @bytesize
  end

  @[AlwaysInline]
  def ==(other : String) : Bool
    bytesize == other.bytesize &&
      LibC.strncmp(self, other, bytesize) == 0
  end

  # @[AlwaysInline]
  # def ==(other : UInt8*) : Bool
  #   LibC.strcmp(self, other) == 0
  # end

  @[AlwaysInline]
  def to_slice : Bytes
    Bytes.new(to_unsafe, bytesize, read_only: true)
  end
end
