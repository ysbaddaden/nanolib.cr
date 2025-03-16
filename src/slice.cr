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

  @[AlwaysInline]
  def size : Int32
    @size
  end

  @[AlwaysInline]
  def bytesize : Int32
    sizeof(T) * @size
  end

  @[AlwaysInline]
  def read_only? : Bool
    @read_only
  end

  def +(offset : Int) : self
    check_in_bounds!(offset)
    Slice.new(@pointer + offset, size &- offset, read_only: read_only?)
  end

  def []=(index : Int32, value : T)
    check_read_only!
    index = check_in_bounds!(index)
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

  @[AlwaysInline]
  def to_unsafe : Pointer(T)
    @pointer
  end

  def sort! : Nil
    n = @size

    (n // 2 &- 1).downto(0) do |i|
      __heapify(n, i)
    end

    (n &- 1).downto(0) do |i|
      to_unsafe[0], to_unsafe[i] = to_unsafe[i], to_unsafe[0]
      __heapify(i, 0)
    end
  end

  private def __heapify(n, i)
    largest = i
    left = 2 &* i &+ 1
    right = 2 &* i &+ 2

    if left < n && to_unsafe[left] > to_unsafe[largest]
      largest = left
    end

    if right < n && to_unsafe[right] > to_unsafe[largest]
      largest = right
    end

    unless largest == i
      to_unsafe[i], to_unsafe[largest] = to_unsafe[largest], to_unsafe[i]
      __heapify(n, largest)
    end
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
