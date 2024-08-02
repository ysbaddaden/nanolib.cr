struct Pointer(T)
  # Overrides the malloc(u64) and realloc(u64) primitives because they call to
  # the garbage collector (`GC`).

  def self.malloc(size : UInt64) : self
    ptr = LibC.malloc(LibC::SizeT.new(size * sizeof(T)))
    errno! "malloc" if ptr.null?
    ptr.as(self)
  end

  @[AlwaysInline]
  def self.malloc(size : Int) : self
    malloc(size.to_u64!)
  end

  # :nodoc:
  @[AlwaysInline]
  def self.malloc(size : Int128 | UInt128) : self
    malloc(size.to_u64)
  end

  def self.realloc(size : UInt64) : self
    ptr = LibC.realloc(self, LibC::SizeT.new(size * sizeof(T)))
    errno! "realloc" if ptr.null?
    ptr.as(self)
  end

  @[AlwaysInline]
  def self.realloc(size : Int) : self
    realloc(size.to_u64!)
  end

  # :nodoc:
  @[AlwaysInline]
  def self.realloc(size : Int128 | UInt128) : self
    realloc(size.to_u64)
  end

  @[AlwaysInline]
  def self.null : self
    new(0)
  end

  @[AlwaysInline]
  def null? : Bool
    address == 0
  end

  @[AlwaysInline]
  def [](offset : Int) : T
    (self + offset).value
  end

  @[AlwaysInline]
  def []=(offset : Int, value : T) : T
    (self + offset).value = value
  end

  @[AlwaysInline]
  def -(offset : Int) : self
    self - offset.to_i64!
  end

  # :nodoc:
  @[AlwaysInline]
  def -(offset : UInt64 | Int128 | UInt128) : self
    self - offset.to_i64
  end

  @[AlwaysInline]
  def -(offset : Int64) : self
    self + (-offset)
  end

  @[AlwaysInline]
  def +(offset : Int) : self
    self + offset.to_i64!
  end

  # :nodoc:
  @[AlwaysInline]
  def +(offset : UInt64 | Int128 | UInt128) : self
    self + offset.to_i64
  end

  @[AlwaysInline]
  def ==(other : self) : Bool
    address == other.address
  end

  @[AlwaysInline]
  def <(other : Pointer(T)) : Bool
    address < other.address
  end

  @[AlwaysInline]
  def <=(other : Pointer(T)) : Bool
    address <= other.address
  end

  @[AlwaysInline]
  def >(other : Pointer(T)) : Bool
    address > other.address
  end

  @[AlwaysInline]
  def >=(other : Pointer(T)) : Bool
    address >= other.address
  end

  @[AlwaysInline]
  def memset(value : UInt8, size = 1) : Nil
    Intrinsics.memset(self.as(Void*), value, LibC::SizeT.new(size * sizeof(T)), false)
  end

  @[AlwaysInline]
  def to_slice(size : Int) : Slice(T)
    Slice.new(self, size)
  end

  @[AlwaysInline]
  def free : Nil
    v = value
    v.finalize if v.responds_to?(:finalize)
    LibC.free(self)
  end

  @[AlwaysInline]
  def to_unsafe
    address
  end
end
