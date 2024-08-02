require "./test_helper"

struct ObjectTest < Nano::Test
  def test_unsafe_as
    assert UInt32::MAX.unsafe_as(Int32) == -1_i32
  end

  def test_tap
    ret = 123.tap do |value|
      assert value == 123
      456
    end
    assert ret == 123
  end

  def test_try
    assert 1_i32.try(&.to_f64).is_a?(Float64)
    assert nil.try(&.to_f).nil?
  end
end
