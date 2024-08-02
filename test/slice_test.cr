require "./test_helper"

struct SliceTest < Nano::Test
  def test_new
    slice = Slice(UInt8).new(1)
    assert slice.is_a?(Slice(UInt8))

    slice = Slice(Int32).new(4) { |i| i * 2 }
    assert slice[0] == 0
    assert slice[1] == 2
    assert slice[2] == 4
    assert slice[3] == 6
  end

  def test_size
    assert Slice(UInt8).new(2).size == 2
    assert Slice(Int32).new(2).size == 2
  end

  def test_bytesize
    assert Slice(UInt8).new(2).bytesize == 2
    assert Slice(Int32).new(2).bytesize == 8
  end

  def test_readonly?
    refute Slice(UInt8).new(2).read_only?
    assert Slice(Int32).new(2, read_only: true).bytesize == 8
  end

  def test_add
    slice = Slice(Int32).new(16)
    sub = slice + 4
    assert sub.is_a?(Slice(Int32))
    refute sub.read_only?
    assert sub.size == 12
    assert sub.bytesize == 48
    assert sub.to_unsafe == slice.to_unsafe + 4

    slice = Slice(Int32).new(12, read_only: true)
    sub = slice + 6
    assert sub.read_only?
    assert sub.size == 6
    assert sub.bytesize == 24
    assert sub.to_unsafe == slice.to_unsafe + 6
  end

  def test_fetch
    slice = Slice(Int32).new(2) { |i| i * 2 }
    assert slice[0] == 0
    assert slice[1] == 2
    assert slice[-1] == 2

    assert_panic do
      other = Slice(Int32).new(2) { |i| i * 2 }
      other[2]
    end

    assert_panic do
      other = Slice(Int32).new(2) { |i| i * 2 }
      other[-3]
    end

    slice = Slice(Int32).new(2, read_only: true) { |i| i * 2 }
    assert slice[0] == 0
    assert slice[1] == 2
  end

  def test_fetch?
    slice = Slice(Int32).new(2) { |i| i * 2 }
    assert slice[0]? == 0
    assert slice[1]? == 2
    assert slice[2]?.nil?
    assert slice[-2]? == 0
    assert slice[-3]?.nil?

    slice = Slice(Int32).new(2, read_only: true) { |i| i * 2 }
    assert slice[0]? == 0
    assert slice[1]? == 2
    assert slice[2]?.nil?
    assert slice[-3]?.nil?
  end

  def test_put
    slice = Slice(Int32).new(2)
    slice[0] = 1
    slice[1] = 2
    assert slice[0] == 1
    assert slice[1] == 2

    assert_panic do
      other = Slice(Int32).new(2, read_only: true)
      other[0] = 1
    end

    assert_panic do
      other = Slice(Int32).new(2, read_only: false) { |i| i * 2 }
      other[3] = 1
    end

    assert_panic do
      other = Slice(Int32).new(2, read_only: false) { |i| i * 2 }
      other[-3] = 1
    end
  end

  def test_fetch_range
    slice = Slice(Int32).new(16) { |i| i }
    sub = slice[3, 6]
    assert sub.is_a?(Slice(Int32))
    refute sub.read_only?
    assert sub.size == 6
    assert sub.to_unsafe == slice.to_unsafe + 3

    sub = slice[5..7]
    assert sub.is_a?(Slice(Int32))
    refute sub.read_only?
    assert sub.size == 3
    assert sub.to_unsafe == slice.to_unsafe + 5

    sub = slice[5...7]
    refute sub.read_only?
    assert sub.size == 2
    assert sub.to_unsafe == slice.to_unsafe + 5

    sub = slice[..7]
    refute sub.read_only?
    assert sub.size == 8
    assert sub.to_unsafe == slice.to_unsafe

    sub = slice[...7]
    refute sub.read_only?
    assert sub.size == 7
    assert sub.to_unsafe == slice.to_unsafe

    sub = slice[7..]
    refute sub.read_only?
    assert sub.size == 9
    assert sub.to_unsafe == slice.to_unsafe + 7

    sub = slice[1..-4]
    refute sub.read_only?
    assert sub.size == 12
    assert sub.to_unsafe == slice.to_unsafe + 1

    sub = slice[-7..-4]
    refute sub.read_only?
    assert sub.size == 4
    assert sub.to_unsafe == slice.to_unsafe + 9

    sub = slice[-6..]
    refute sub.read_only?
    assert sub.size == 6
    assert sub.to_unsafe == slice.to_unsafe + 10

    sub = slice[..-4]
    refute sub.read_only?
    assert sub.size == 13
    assert sub.to_unsafe == slice.to_unsafe

    sub = slice[...-4]
    refute sub.read_only?
    assert sub.size == 12
    assert sub.to_unsafe == slice.to_unsafe

    slice = Slice(Int32).new(16, read_only: true)
    assert slice[3, 6].read_only?
    assert slice[5..7].read_only?
    assert slice[5...7].read_only?
  end

  # def test_fetch_range?
  # end

  def test_to_unsafe
    skip
  end
end
