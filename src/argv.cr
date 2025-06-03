module ARGV
  def self.[](index : Int32) : Bytes
    index &+= 1
    panic! "Index out of bounds" unless index < ARGC_UNSAFE
    ptr = (ARGV_UNSAFE + index).value
    Slice.new(ptr, String.bytesize(ptr), read_only: true)
  end

  def self.[]?(index : Int32) : Bytes?
    index &+= 1
    unless index < ARGC_UNSAFE
      ptr = (ARGV_UNSAFE + index).value
      Slice.new(ptr, String.bytesize(ptr), read_only: true)
    end
  end

  def self.each(& : Bytes ->) : Nil
    (ARGC_UNSAFE &- 1).times { |index| yield self[index] }
  end
end
