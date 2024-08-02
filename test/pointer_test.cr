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

  def test_equality
    assert Pointer(UInt8).new(123) == Pointer(UInt8).new(123)
    refute Pointer(UInt8).new(1) == Pointer(UInt8).new(2)
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
end
