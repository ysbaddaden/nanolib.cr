require "../../src/nano"
require "../../src/spec"

describe "Foo" do
  let(:truthy) { true }

  it "spec" do
    assert truthy
    refute false
  end
end
