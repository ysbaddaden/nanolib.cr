require "c/stdint"
require "c/stdlib"
require "c/profileapi"

module Nano
  def self.exit(status : Int32) : NoReturn
    LibC.exit(status)
  end

  def self.clock_monotonic : {Int64, Int32}
    LibC.QueryPerformanceCounter(out ticks)
    LibC.QueryPerformanceFrequency(out frequency)
    seconds = ticks // frequency
    nanoseconds = (ticks.remainder(frequency) &* 1_000_000_000 // frequency).to_i32!
    {seconds, nanoseconds}
  end
end
