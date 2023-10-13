lib LibC
  fun strncmp(Char*, Char*, SizeT) : Int
end

class String
  def to_unsafe : UInt8*
    pointerof(@c)
  end

  def bytesize : Int32
    @bytesize
  end

  def ==(other : String) : Bool
    bytesize == other.bytesize &&
      LibC.strncmp(self, other, bytesize) == 0
  end
end
