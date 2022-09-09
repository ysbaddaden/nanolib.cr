require "math/libm"

struct Float
  alias Primitive = Float32 | Float64

  def nan? : Bool
    !(self == self)
  end

  def infinite? : Int32?
    unless nan? || self == 0 || self != 2 * self
      self > 0 ? 1 : -1
    end
  end

  def finite? : Bool
    !nan? && !infinite?
  end

  def <=>(other : self) : Int32?
    super unless nan? || other.nan?
  end

  def -
    self.class.zero - self
  end

  def //(other : self) : self
    (self / other).floor
  end

  def tdiv(other : self) : self
    (self / other).trunc
  end

  def modulo(other : self) : self
    if other == 0
      panic! "division by zero"
    else
      self - other * (self // other)
    end
  end

  def remainder(other : self) : self
    if other == 0
      panic! "division by zero"
    else
      mod = modulo(other)
      return self.class.zero if mod == 0
      return mod if self > 0 && other > 0
      return mod if self < 0 && other < 0

      mod - other
    end
  end

  def round(digits : Int32, base = 10) : self
    if digits < 0
      multiplier = self.class.new(base) ** digits.abs
      shifted = self / multiplier
      self.class.new(shifted.round * multiplier)
    else
      multiplier = self.class.new(base) ** digits
      shifted = self * multiplier
      self.class.new(shifted.round / multiplier)
    end
  end
end

struct Float32
  NAN      = (0_f32 / 0_f32).as(Float32)
  INFINITY = (1_f32 / 0_f32).as(Float32)
  MIN = -3.40282347e+38_f32
  MAX = 3.40282347e+38_f32
  EPSILON = 1.19209290e-07_f32
  DIGITS = 6
  RADIX = 2
  MANT_DIGITS = 24
  MIN_EXP = -125
  MAX_EXP = 128
  MIN_10_EXP = -37
  MAX_10_EXP = 38
  MIN_POSITIVE = 1.17549435e-38_f32

  def self.new(value) : Float32
    value.to_f32
  end

  def self.new!(value) : Float32
    value.to_f32!
  end

  def ceil : Float32
    LibM.ceil_f32(self)
  end

  def floor : Float32
    LibM.floor_f32(self)
  end

  def **(other : Float32) : Float32
    LibM.pow_f32(self, other)
  end

  def **(other : Int32) : Float32
    LibM.powi_f32(self, other)
  end

  def round : Float32
    # TODO: LLVM 11 introduced llvm.roundeven.* intrinsics
    LibM.rint_f32(self)
  end

  def trunc : Float32
    LibM.trunc_f32(self)
  end
end

struct Float64
  NAN      = (0_f64 / 0_f64).as(Float64)
  INFINITY = (1_f64 / 0_f64).as(Float64)
  MIN = -1.7976931348623157e+308_f64
  MAX = 1.7976931348623157e+308_f64
  EPSILON = 2.2204460492503131e-16_f64
  DIGITS = 15
  RADIX = 2
  MANT_DIGITS = 53
  MIN_EXP = -1021
  MAX_EXP = 1024
  MIN_10_EXP = -307
  MAX_10_EXP = 308
  MIN_POSITIVE = 2.2250738585072014e-308_f64

  def self.new(value) : Float64
    value.to_f64
  end

  def self.new!(value) : Float64
    value.to_f64!
  end

  def **(other : Float64) : Float64
    LibM.pow_f64(self, other)
  end

  def **(other : Int32) : Float64
    LibM.powi_f64(self, other)
  end

  def ceil : Float64
    LibM.ceil_f64(self)
  end

  def floor : Float64
    LibM.floor_f64(self)
  end

  def round : Float64
    # TODO: LLVM 11 introduced llvm.roundeven.* intrinsics
    LibM.rint_f64(self)
  end

  def trunc : Float64
    LibM.trunc_f64(self)
  end
end
