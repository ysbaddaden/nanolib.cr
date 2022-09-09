struct Pointer(T)
  # overrides the malloc(u64) and realloc(u64) primitives because they call to GC!

  def self.malloc(size : UInt64) : self
    ptr = LibC.malloc(LibC::SizeT.new(size * sizeof(T)))
    errno! "malloc" if ptr.null?
    ptr.as(self)
  end

  def self.realloc(size : UInt64) : self
    ptr = LibC.realloc(self, LibC::SizeT.new(size * sizeof(T)))
    errno! "realloc" if ptr.null?
    ptr.as(self)
  end

  def self.malloc(size : Int) : self
    malloc(size.to_u64)
  end

  def self.realloc(size : Int) : self
    realloc(size.to_u64)
  end

  def self.null : self
    new(0)
  end

  def null? : Bool
    address == 0
  end

  def [](offset : Int) : T
    (self + offset).value
  end

  def []=(offset : Int, value : T) : T
    (self + offset).value = value
  end

  def -(offset : Int) : self
    self - offset.to_i64!
  end

  def -(offset : Int64) : self
    self + (-offset)
  end

  def +(offset : Int) : self
    self + offset.to_i64!
  end

  def null? : Bool
    address == 0
  end

  def ==(other : self) : Bool
    address == other.address
  end

  # def to_slice(size) : Slice(T)
  #   Slice.new(self, size)
  # end
end
