struct StaticArray(T, N)
  macro [](*args)
    %array = uninitialized StaticArray(typeof({{*args}}), {{args.size}})
    {% for arg, i in args %}
      %array.to_unsafe[{{i}}] = {{arg}}
    {% end %}
    %array
  end

  def []=(index : Int32, value : T)
    check_in_bounds!(index)
    to_unsafe[index] = value
  end

  def [](index : Int32) : T
    check_in_bounds!(index)
    to_unsafe[index]
  end

  def []?(index : Int32) : T?
    to_unsafe[index] if in_bounds?(index)
  end

  def size : Int32
    N
  end

  def to_slice : Slice(T)
    Slice.new(to_unsafe, size)
  end

  def to_unsafe : Pointer(T)
    pointerof(@buffer)
  end

  private def check_in_bounds!(index : Int32)
    unless in_bounds?(index)
      panic! "out of bounds (index=%lld, size=%lld)", index.to_u64, size.to_u64
    end
  end

  private def in_bounds?(index : Int32) : Bool
    index += size if index < 0
    0 <= index < @size
  end
end
