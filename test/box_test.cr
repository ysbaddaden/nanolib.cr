require "./test_helper"

struct BoxTest < Nano::Test
  def test_allocated_on_the_stack
    box = Box.new(123_i32)
    value = Box(Int32).unbox(pointerof(box).as(Void*))
    assert value == 123_i32
  end

  def test_allocated_on_the_heap
    box = Box(Int32).malloc(124_i32)
    value = Box(Int32).unbox(box.as(Void*))
    assert value == 124_i32
    box.free
  end
end
