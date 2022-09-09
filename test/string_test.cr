require "./test_helper"

struct StringTest < Microtest::Test
  def test_bytesize
    assert "azertyuiop".bytesize == 10
    assert("日本語".bytesize == 9)
  end

  def test_to_unsafe
    str = "azerty"
    assert str.to_unsafe == pointerof(str.@c)
  end
end
