require "./test_helper"

struct PointerTest < Nano::Test
  def test_malloc
    ptr = Pointer(UInt8).malloc(1)
    assert ptr.is_a?(Pointer(UInt8))
    ptr.free
  end

  def test_realloc
    ptr = Pointer(UInt8).malloc(1)
    ptr.value = 127_u8
    new_ptr = ptr.realloc(128)
    assert new_ptr.value = 127_u8
    new_ptr.free
  end

  def test_null
    assert Pointer(UInt8).null == Pointer(UInt8).new(0)
    refute Pointer(UInt8).new(1) == Pointer(UInt8).null
  end

  def test_null?
    assert Pointer(UInt8).new(0).null?
    refute Pointer(UInt8).new(1).null?
  end

  def test_get
    x = 1
    xp = pointerof(x)
    assert xp[0] == 1
  end

  def test_set
    x = 1
    xp = pointerof(x)
    xp[0] = 2
    assert xp[0] == 2
  end

  def test_add
    assert Pointer(UInt8).new(123) + 10 == Pointer(UInt8).new(133)
    assert Pointer(UInt8).new(1) + 1 == Pointer(UInt8).new(2)
  end

  def test_sub
    assert Pointer(UInt8).new(123) - 10 == Pointer(UInt8).new(113)
    assert Pointer(UInt8).new(1) - 1 == Pointer(UInt8).new(0)
  end

  def test_lower_than
    refute Pointer(UInt8).new(123) < Pointer(UInt8).new(123)
    assert Pointer(UInt8).new(1) < Pointer(UInt8).new(2)
    refute Pointer(UInt8).new(2) < Pointer(UInt8).new(1)
  end

  def test_lower_than_or_equal
    assert Pointer(UInt8).new(123) <= Pointer(UInt8).new(123)
    assert Pointer(UInt8).new(1) <= Pointer(UInt8).new(2)
    refute Pointer(UInt8).new(2) <= Pointer(UInt8).new(1)
  end

  def test_equal
    assert Pointer(UInt8).new(123) == Pointer(UInt8).new(123)
    refute Pointer(UInt8).new(1) == Pointer(UInt8).new(2)
    refute Pointer(UInt8).new(2) == Pointer(UInt8).new(1)
  end

  def test_greater_than
    refute Pointer(UInt8).new(123) > Pointer(UInt8).new(123)
    refute Pointer(UInt8).new(1) > Pointer(UInt8).new(2)
    assert Pointer(UInt8).new(2) > Pointer(UInt8).new(1)
  end

  def test_greater_than_or_equal
    assert Pointer(UInt8).new(123) >= Pointer(UInt8).new(123)
    refute Pointer(UInt8).new(1) >= Pointer(UInt8).new(2)
    assert Pointer(UInt8).new(2) >= Pointer(UInt8).new(1)
  end

  def test_memset
    ptr = Pointer(UInt32).malloc(16)
    ptr.memset(0x12_u32, 16)
    (0...16).each { |i| assert ptr[i] == 0x12121212_u32 }
  end

  def test_clear
    ptr = Pointer(UInt32).malloc(16)
    ptr.memset(1_u32, 16)
    ptr.clear(4)
    (0...4).each { |i| assert ptr[i] == 0_u32 }
    (4...16).each { |i| assert ptr[i] == 0x01010101_u32 }
  end

  def test_slice
    ptr = Pointer(UInt32).malloc(16)
    slice = ptr.to_slice(8)
    assert slice.is_a?(Slice(UInt32))
    assert slice.size == 8
  end
end
