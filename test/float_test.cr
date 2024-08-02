require "./test_helper"

struct FloatTest < Nano::Test
  def test_nan?
    assert Float32::NAN.nan?
    refute 1_f32.nan?

    assert Float64::NAN.nan?
    refute 1_f64.nan?
  end

  def test_infinite?
    assert Float32::NAN.infinite?.nil?
    assert 0_f32.infinite?.nil?
    assert Float32::INFINITY.infinite? == 1
    assert (-Float32::INFINITY).infinite? == -1

    assert Float64::NAN.infinite?.nil?
    assert 0_f64.infinite?.nil?
    assert Float64::INFINITY.infinite? == 1
    assert (-Float64::INFINITY).infinite? == -1
  end

  def test_finite?
    refute Float32::NAN.finite?
    refute Float32::INFINITY.finite?
    assert 1_f32.finite?

    refute Float64::NAN.finite?
    refute Float64::INFINITY.finite?
    assert 1_f64.finite?
  end

  def test_compare
    assert (-2.0 <=> 3.0) == -1.0
    assert (1.0 <=> 2.0) == -1.0

    assert (2.0 <=> 2.0) == 0.0
    assert (-2.0 <=> -2.0) == 0.0

    assert (3.0 <=> 2.0) == 1.0
    assert (3.0 <=> -2.0) == 1.0

    assert (Float32::NAN <=> Float32::NAN).nil?
    assert (Float64::NAN <=> Float64::NAN).nil?
  end

  def test_unary_minus
    {% for bits in [32, 64] %}
      x{{bits}} = 56_f{{bits}}
      assert -x{{bits}} == -56_f{{bits}}
    {% end %}
  end

  def test_unary_plus
    {% for bits in [32, 64] %}
      x{{bits}} = 78_f{{bits}}
      assert +x{{bits}} == 78_f{{bits}}
    {% end %}
  end

  def test_floor_division
    assert 1.0 / 2.0 == 0.5
    assert -12.0 / 6.0 == -2.0
    assert 1.0 / 0.0 == Float64::INFINITY
  end

  def test_tdiv
    assert 1.0 // 2.0 == 0.0
    assert -1.0 // 2.0 == -1.0
    assert 1.0 / 0.0 == Float64::INFINITY
  end

  def test_modulo
    {% for bits in [32, 64] %}
      assert 0_f{{bits}} % 2_f{{bits}} == 0_f{{bits}}
      assert 1_f{{bits}} % 2_f{{bits}} == 1_f{{bits}}
      assert 2_f{{bits}} % 2_f{{bits}} == 0_f{{bits}}
      assert 3_f{{bits}} % 2_f{{bits}} == 1_f{{bits}}
      assert 123_f{{bits}} % 5_f{{bits}} == 3_f{{bits}}
      assert_panic { 1_f{{bits}} % 0_f{{bits}} }
    {% end %}
  end

  def test_remainder
    {% for bits in [32, 64] %}
      assert 4_f{{bits}}.remainder(2_f{{bits}}) == 0_f{{bits}}
      assert 5_f{{bits}}.remainder(2_f{{bits}}) == 1_f{{bits}}
      assert_panic { 1_f{{bits}}.remainder(0_f{{bits}}) }
    {% end %}
  end

  def test_round
    {% for bits in [32, 64] %}
      assert 1.5_f{{bits}}.round == 2_f{{bits}}
      assert 2.7_f{{bits}}.round == 3_f{{bits}}
      assert -2.2_f{{bits}}.round == -2_f{{bits}}
      assert -2.7_f{{bits}}.round == -3_f{{bits}}

      assert 1.12345_f{{bits}}.round(0) == 1_f{{bits}}
      assert 1.12345_f{{bits}}.round(1) == 1.1_f{{bits}}
      assert 1.12345_f{{bits}}.round(2) == 1.12_f{{bits}}
      assert 1.12345_f{{bits}}.round(3) == 1.123_f{{bits}}

      assert 12345_f{{bits}}.round(0) == 12345_f{{bits}}
      assert 12345_f{{bits}}.round(-1) == 12340_f{{bits}}
      assert 12345_f{{bits}}.round(-2) == 12300_f{{bits}}
      assert 12345_f{{bits}}.round(-3) == 12000_f{{bits}}
    {% end %}
  end

  def test_ceil
    {% for bits in [32, 64] %}
      assert 1.5_f{{bits}}.ceil == 2_f{{bits}}
      assert 2.7_f{{bits}}.ceil == 3_f{{bits}}
      assert -2.2_f{{bits}}.ceil == -2_f{{bits}}
      assert -2.7_f{{bits}}.ceil == -2_f{{bits}}
    {% end %}
  end

  def test_floor
    {% for bits in [32, 64] %}
      assert 1.5_f{{bits}}.floor == 1_f{{bits}}
      assert 2.7_f{{bits}}.floor == 2_f{{bits}}
      assert -2.2_f{{bits}}.floor == -3_f{{bits}}
      assert -2.7_f{{bits}}.floor == -3_f{{bits}}
    {% end %}
  end

  def test_trunc
    {% for bits in [32, 64] %}
      assert 1.5_f{{bits}}.trunc == 1_f{{bits}}
      assert 2.7_f{{bits}}.trunc == 2_f{{bits}}
      assert -2.2_f{{bits}}.trunc == -2_f{{bits}}
      assert -2.7_f{{bits}}.trunc == -2_f{{bits}}
    {% end %}
  end

  def test_exponent
    assert 1.0 ** 2.0 == 1.0
    assert 2.0 ** 3.0 == 8.0
    assert Float32::MAX ** 2 == Float32::INFINITY
    assert Float32::MAX ** -1 == 2.938736e-39_f32

    assert 1.0 ** 2.0 == 1.0
    assert 2.0 ** 3.0 == 8.0
    assert Float64::MAX ** 2 == Float64::INFINITY
    assert Float64::MAX ** -1 == 5.562684646268003e-309
  end
end
