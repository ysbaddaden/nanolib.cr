struct Int
  alias Signed = Int8 | Int16 | Int32 | Int64 | Int128
  alias Unsigned = UInt8 | UInt16 | UInt32 | UInt64 | UInt128
  alias Primitive = Signed | Unsigned

  def ~ : self
    self ^ -1
  end

  def <<(count : Signed) : self
    if count < 0
      self >> count.abs
    elsif count < sizeof(self) * 8
      unsafe_shl(count)
    else
      self.class.zero
    end
  end

  def >>(count : Signed) : self
    if count < 0
      self << count.abs
    elsif count < sizeof(self) * 8
      unsafe_shr(count)
    else
      self.class.zero
    end
  end

  def <<(count : Unsigned) : self
    if count < sizeof(self) * 8
      unsafe_shl(count)
    else
      self.class.zero
    end
  end

  def >>(count : Unsigned) : self
    if count < sizeof(self) * 8
      unsafe_shr(count)
    else
      self.class.zero
    end
  end

  # Float division.
  def /(other : self) : Float64
    to_f64 / other.to_f64
  end

  # Floor division.
  def //(other : self) : self
    check_div_argument(other)
    div = unsafe_div(other)
    mod = unsafe_mod(other)

    if other > 0 ? mod < 0 : mod > 0
      div - 1
    else
      div
    end
  end

  # Truncated division.
  def tdiv(other : self) : self
    check_div_argument(other)
    unsafe_div(other)
  end

  def **(exponent : self) : self
    if exponent < 0
      panic! "can't raise an integer to a negative integer power, use floats for that"
    end

    result = self.class.new(1)
    k = self
    while exponent > 0
      result *= k if exponent & 0b1 != 0
      exponent = exponent.unsafe_shr(1)
      k *= k if exponent > 0
    end
    result
  end

  def &**(exponent : self) : self
    if exponent < 0
      panic! "can't raise an integer to a negative integer power, use floats for that"
    end

    result = self.class.new(1)
    k = self
    while exponent > 0
      result &*= k if exponent & 0b1 != 0
      exponent = exponent.unsafe_shr(1)
      k &*= k if exponent > 0
    end
    result
  end

  private def check_div_argument(other : Signed) : Nil
    panic! "division by zero" if other == 0

    {% begin %}
      if self == {{@type}}::MIN && other == -1
        panic! "overflow: {{@type}}::MIN / -1"
      end
    {% end %}
  end

  private def check_div_argument(other : Unsigned) : Nil
    panic! "division by zero" if other == 0
  end

  def succ : self
    self + 1
  end

  def pred : self
    self - 1
  end

  def times : Nil
    i = self.class.zero
    while i < self
      yield i
      i += 1
    end
  end

  def upto(other : self) : Nil
    i = self
    while i <= other
      yield i
      i += 1
    end
  end

  def downto(other : self) : Nil
    i = self
    while i >= other
      yield i
      i -= 1
    end
  end
end

{% for bits in [8, 16, 32, 64, 128] %}
  struct Int{{bits}}
    def self.new(value) : self
      value.to_i{{bits}}
    end

    def self.new!(value) : self
      value.to_i{{bits}}!
    end

    def - : self
      self.class.zero - self
    end

    def abs : self
      self >= 0 ? self : -self
    end

    def modulo(other : self) : self
      if other == 0
        panic! "division by zero"
      elsif self == MIN && other == -1
        self.class.zero
      elsif (self < 0) == (other < 0)
        unsafe_mod(other)
      else
        me = unsafe_mod(other)
        me == 0 ? me : me + other
      end
    end

    def remainder(other : self) : self
      if other == 0
        panic! "division by zero"
      elsif self == MIN && other == -1
        self.class.zero
      else
        unsafe_mod other
      end
    end

    def leading_zeros_count : self
      Intrinsics.countleading{{bits}}(self, false)
    end

    def trailing_zeros_count : self
      Intrinsics.counttrailing{{bits}}(self, false)
    end
  end

  struct UInt{{bits}}
    MIN = zero
    MAX = ~MIN

    def self.new(value) : self
      value.to_u{{bits}}
    end

    def self.new!(value) : self
      value.to_u{{bits}}!
    end

    def modulo(other : self) : self
      if other == 0
        panic! "division by zero"
      else
        unsafe_mod(other)
      end
    end

    def remainder(other : self) : self
      if other == 0
        panic! "division by zero"
      else
        unsafe_mod(other)
      end
    end

    def leading_zeros_count : Int{{bits}}
      Intrinsics.countleading{{bits}}(self, false)
    end

    def trailing_zeros_count : Int{{bits}}
      Intrinsics.counttrailing{{bits}}(self, false)
    end
  end
{% end %}

struct Int8
  MIN = -128_i8
  MAX =  127_i8
end

struct Int16
  MIN = -32768_i16
  MAX =  32767_i16
end

struct Int32
  MIN = -2147483648_i32
  MAX =  2147483647_i32
end

struct Int64
  MIN = -9223372036854775808_i64
  MAX =  9223372036854775807_i64
end

struct Int128
  MIN = new(1) << 127
  MAX = ~MIN
end

{% if flag?(:win32) %}
  require "crystal/compiler_rt"
{% end %}
