struct Slice(T)
  def self.new(size : Int32, *, read_only = false)
    ptr = Pointer(T).malloc(size.to_u64!)
    new(ptr, size, read_only: read_only)
  end

  def self.new(size : Int32, *, read_only = false)
    ptr = Pointer(T).malloc(size.to_u64!)
    size.times { |i| ptr[i] = yield i }
    new(ptr, size, read_only: read_only)
  end

  def self.new(size : Int32, value : T, *, read_only = false)
    new(size, read_only: read_only) { value }
  end

  def initialize(@pointer : Pointer(T), @size : Int32, *, @read_only = false)
  end

  def each(& : T ->) : Nil
    ptr = @pointer
    stop = ptr + @size

    until ptr == stop
      yield ptr.value
      ptr += 1
    end
  end

  def size : Int32
    @size
  end

  def bytesize : Int32
    sizeof(T) * @size
  end

  def read_only? : Bool
    @read_only
  end

  def +(offset : Int) : self
    check_in_bounds!(offset)
    Slice.new(@pointer + offset, size &- offset, read_only: read_only?)
  end

  def []=(index : Int32, value : T)
    check_read_only!
    size = check_in_bounds!(index)
    @pointer[index] = value
  end

  def [](index : Int32) : T
    index = check_in_bounds!(index)
    @pointer[index]
  end

  def []?(index : Int32) : T?
    if index = in_bounds?(index)
      @pointer[index]
    end
  end

  def [](start : Int32, count : Int32) : self
    start = check_in_bounds!(start)
    check_in_bounds!(start + count)
    panic! "negative size" if count < 0
    Slice.new(@pointer + start, count, read_only: read_only?)
  end

  # def []?(start : Int32, count : Int32) : self?
  #   if (start = in_bounds?(start)) && in_bounds?(start + count) && count >= 0
  #     Slice.new(@pointer + start, count, read_only: read_only?)
  #   end
  # end

  def [](range : Range(Int32, Int32)) : self
    rbegin = range.begin < 0 ? range.begin + size : range.begin
    rend = range.end < 0 ? range.end + size : range.end
    count = rend - rbegin
    count += 1 unless range.exclusive?
    self[rbegin, count]
  end

  def [](range : Range(Nil, Int32)) : self
    count = range.end < 0 ? range.end + size : range.end
    count += 1 unless range.exclusive?
    count = check_in_bounds!(count)
    Slice.new(@pointer, count, read_only: read_only?)
  end

  def [](range : Range(Int32, Nil)) : self
    start = check_in_bounds!(range.begin)
    Slice.new(@pointer + start, size - start, read_only: read_only?)
  end

  # def []?(range : Range(Int32, Int32)) : self?
  # end

  # def []?(range : Range(Nil, Int32)) : self?
  # end

  # def []?(range : Range(Int32, Nil)) : self?
  # end

  def to_unsafe : Pointer(T)
    @pointer
  end

  private def check_read_only!
    panic! "read only slice" if read_only?
  end

  private def check_in_bounds!(index : Int32)
    if actual_index = in_bounds?(index)
      actual_index
    else
      panic! "out of bounds (index=%lld, size=%lld)", index.to_u64, size.to_u64
    end
  end

  private def in_bounds?(index : Int32) : Int32?
    index += size if index < 0
    index if 0 <= index < @size
  end
end

alias Bytes = Slice(UInt8)
