require "c/stdlib"
require "c/sys/time"
require "c/time"

module Nano
  def self.exit(status : Int32) : NoReturn
    LibC.exit(status)
  end

  def self.clock_monotonic : {Int64, Int32}
    ret = LibC.clock_gettime(LibC::CLOCK_MONOTONIC, out timespec)
    errno! "clock_gettime(CLOCK_MONOTONIC)" unless ret == 0
    {timespec.tv_sec.to_i64!, timespec.tv_nsec.to_i32!}
  end
end
