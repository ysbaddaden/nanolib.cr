require "./test_helper"

struct RangeTest < Nano::Test
  def test_initialize
    range = 0..10
    assert range.begin == 0
    assert range.end == 10
    refute range.exclusive?

    range = 5..12
    assert range.begin == 5
    assert range.end == 12
    refute range.exclusive?

    range = 5...12
    assert range.begin == 5
    assert range.end == 12
    assert range.exclusive?
  end

  def test_equality
    assert (5..10) == (5..10)
    assert (5...10) == (5...10)
    refute (5...10) == (5..10)
  end

  def test_each
    j = 4
    (5..10).each { |i| assert i == (j += 1) }
  end
end
