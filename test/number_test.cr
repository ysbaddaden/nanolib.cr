require "./test_helper"

struct NumberTest < Microtest::Test
  def test_zero
    assert Int8.zero == 0_i8
    assert Int16.zero == 0_i16
    assert Int32.zero == 0_i32
    assert Int64.zero == 0_i64
    assert Int128.zero == 0_i128

    assert UInt8.zero == 0_u8
    assert UInt16.zero == 0_u16
    assert UInt32.zero == 0_u32
    assert UInt64.zero == 0_u64
    assert UInt128.zero == 0_u128

    assert Float32.zero == 0_f32
    assert Float64.zero == 0_f64
  end

  def test_compare
    assert (-2 <=> 3) == -1
    assert (1 <=> 2) == -1

    assert (2 <=> 2) == 0
    assert (-2 <=> -2) == 0

    assert (3 <=> 2) == 1
    assert (3 <=> -2) == 1
  end
end
