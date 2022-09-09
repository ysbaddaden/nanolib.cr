require "./test_helper"

struct EnumTest < Microtest::Test
  enum Value
    ONE
    TWO
    THREE
  end

  @[Flags]
  enum Flag
    NONE = 0
    ONE = 1
    TWO = 2
    THREE = 4
    ALL = 7
  end

  def test_equality
    assert Value::ONE == Value::ONE
    assert Value::TWO.== Value::TWO

    assert Value::ONE === Value::ONE
    assert Value::THREE.=== Value::THREE
  end

  def test_bitwise_or
    assert (Flag::ONE | Flag::TWO).value == 3
  end

  def test_bitwise_and
    assert (Flag::ONE & Flag::TWO) == Flag::NONE
    assert (Flag::ONE & Flag::ONE) == Flag::ONE
    assert (Flag::ALL & Flag::THREE) == Flag::THREE
  end

  def test_bitwise_xor
    assert (Flag::ALL ^ Flag::THREE) == Flag::ONE | Flag::TWO
  end
end
