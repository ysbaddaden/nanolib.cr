require "../../src/nano"
require "../../src/test"

struct FooTest < Nano::Test
  def test_bar
    assert true
    refute false
  end
end
