class String
  def to_unsafe : UInt8*
    pointerof(@c)
  end

  def bytesize : Int32
    @bytesize
  end
end
