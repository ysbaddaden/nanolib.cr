class String
  def self.bytesize(pointer : UInt8*) : Int32
    bytesize = 0
    until (pointer + bytesize).value == 0_u8
      bytesize &+= 1
    end
    bytesize
  end

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
      to_unsafe.memcmp(other.to_unsafe, bytesize) == 0
  end

  @[AlwaysInline]
  def ==(other : Bytes) : Bool
    bytesize == other.size &&
      to_unsafe.memcmp(other.to_unsafe, bytesize) == 0
  end

  # @[AlwaysInline]
  # def ==(other : UInt8*) : Bool
  #   bytesize == String.bytesize(other) &&
  #     to_unsafe.memcmp(other.to_unsafe, bytesize) == 0
  # end

  @[AlwaysInline]
  def to_slice : Bytes
    Bytes.new(to_unsafe, bytesize, read_only: true)
  end
end
