require "./test_helper"

struct IntTest < Microtest::Test
  def test_unary_minus
    {% for bits in [8, 16, 32, 64, 128] %}
      x{{bits}} = 56_i{{bits}}
      assert -x{{bits}} == -56_i{{bits}}
    {% end %}
  end

  def test_unary_plus
    {% for bits in [8, 16, 32, 64, 128] %}
      x{{bits}} = 78_i{{bits}}
      assert +x{{bits}} == 78_i{{bits}}
    {% end %}
  end

  def test_bitwise_complement
    assert ~1 == -2
    assert ~-2 == 1
    assert ~Int32::MIN == Int32::MAX
    assert ~Int32::MAX == Int32::MIN
  end

  def test_bitwise_shift_left
    assert 1 << 3 == 8
    assert 1 << -2 == 4
    assert 1 << 31 == Int32::MIN

    assert 1_u32 << 3 == 8
    assert 1_u32 << 32 == 0
  end

  def test_bitwise_shift_left
    assert 8 >> 3 == 1
    assert 8 >> -2 == 32
    assert Int32::MAX >> 30 == 1
    assert Int32::MAX >> 31 == 0
    assert Int32::MAX >> 32 == 0

    assert 8_u32 >> 3 == 1
    assert UInt32::MAX >> 31 == 1
    assert UInt32::MAX >> 32 == 0
  end

  def test_abs
    {% for bits in [8, 16, 32, 64, 128] %}
      assert 12_i{{bits}}.abs == 12_i{{bits}}
      assert -34_i{{bits}}.abs == 34_i{{bits}}
    {% end %}
  end

  def test_float_division
    assert 1 / 2 == 0.5_f64
    assert -12 / 6 == -2_f64
    assert 1 / 0 == Float64::INFINITY
  end

  def test_floor_division
    assert 1 // 2 == 0
    assert -1 // 2 == -1
    assert_panic { 1 // 0 } # division by zero
    assert_panic { Int32::MIN // -1 } # overflow
  end

  def test_tdiv
    assert 1.tdiv(2) == 0
    assert -1.tdiv(2) == 0
    assert_panic { 1.tdiv(0) } # division by zero
    assert_panic { Int32::MIN.tdiv(-1) } # overflow
  end

  def test_exponent
    assert 1 ** 2 == 1
    assert 2 ** 3 == 8
    assert_panic { 12_u8 ** 4 } # overflow
  end

  def test_wrapping_exponent
    assert 1 &** 2 == 1
    assert 2 &** 3 == 8
    assert 12_i8 &** 2 == -112
    assert 12_u8 &** 2 == 144
    assert 12_u8 &** 4 == 0
    assert_panic { 123 ** -2 } # raise int to negative int
  end

  def test_modulo
    {% for bits in [8, 16, 32, 64, 128] %}
      assert 0_i{{bits}} % 2_i{{bits}} == 0_i{{bits}}
      assert 1_i{{bits}} % 2_i{{bits}} == 1_i{{bits}}
      assert 2_i{{bits}} % 2_i{{bits}} == 0_i{{bits}}
      assert 3_i{{bits}} % 2_i{{bits}} == 1_i{{bits}}
      assert 123_i{{bits}} % 5_i{{bits}} == 3_i{{bits}}
      assert Int{{bits}}::MIN % -1_i{{bits}} == 0_i{{bits}}
      assert_panic { 123_i{{bits}} % 0_i{{bits}} } # division by zero

      assert 0_u{{bits}} % 2_u{{bits}} == 0_u{{bits}}
      assert 1_u{{bits}} % 2_u{{bits}} == 1_u{{bits}}
      assert 2_u{{bits}} % 2_u{{bits}} == 0_u{{bits}}
      assert 3_u{{bits}} % 2_u{{bits}} == 1_u{{bits}}
      assert 123_u{{bits}} % 5_u{{bits}} == 3_u{{bits}}
      assert_panic { 123_u{{bits}} % 0_u{{bits}} } # division by zero
    {% end %}

  end

  def test_remainder
    {% for bits in [8, 16, 32, 64, 128] %}
      assert 4_i{{bits}}.remainder(2_i{{bits}}) == 0_i{{bits}}
      assert 5_i{{bits}}.remainder(2_i{{bits}}) == 1_i{{bits}}
      assert_panic { 123_i{{bits}}.remainder(0_i{{bits}}) } # division by zero
      assert Int{{bits}}::MIN.remainder(-1_i{{bits}}) == 0_i{{bits}}

      assert 4_u{{bits}}.remainder(2_u{{bits}}) == 0_u{{bits}}
      assert 5_u{{bits}}.remainder(2_u{{bits}}) == 1_u{{bits}}
      assert_panic { 123_u{{bits}}.remainder(0_u{{bits}}) } # division by zero
    {% end %}
  end

  def test_times
    total = 0
    ret = 5.times { |i| total += i }
    assert ret.nil?
    assert total == 10
  end

  def test_upto
    total = 0
    ret = 2.upto(8) { |i| total += i }
    assert ret.nil?
    assert total == 35

    total = 0
    8.upto(2) { |i| total += i }
    assert total == 0
  end

  def test_downto
    total = 0
    ret = 7.downto(5) { |i| total += i }
    assert ret.nil?
    assert total == 18

    total = 0
    2.downto(8) { |i| total += i }
    assert total == 0
  end
end
