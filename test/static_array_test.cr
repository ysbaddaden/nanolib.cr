require "./test_helper"

struct StaticArrayTest < Nano::Test
  def test_size
    array = uninitialized UInt8[128]
    assert array.size == 128
  end

  def test_to_unsafe
    array = uninitialized UInt8[32]
    assert array.to_unsafe == pointerof(array.@buffer)
  end
end
