require "c/dlfcn"
require "c/stdio"
require "c/stdlib"
require "c/pthread"
require "exception/lib_unwind"
require "./box"

lib LibC
  fun pthread_exit(Void*) : NoReturn

  {% if flag?(:darwin) || flag?(:dragonfly) || flag?(:freebsd) || flag?(:netbsd) || flag?(:openbsd) %}
    fun pthread_main_np : Int
  {% end %}
end

module Nano
  {% if flag?(:darwin) || flag?(:dragonfly) || flag?(:freebsd) || flag?(:netbsd) || flag?(:openbsd) %}
    def self.main_thread? : Bool
      LibC.pthread_main_np == 1
    end
  {% else %}
    @@main_thread = LibC.pthread_self

    def self.main_thread? : Bool
      LibC.pthread_self == @@main_thread
    end
  {% end %}

  @[ThreadLocal]
  @@silenced_panic = false

  def self.silenced_panic? : Bool
    @@silenced_panic
  end

  def self.silenced_panic=(@@silenced_panic : Bool)
  end
end

# Prints a message on STDERR and immediately exits the program with an error
# status.
def abort!(message, file = __FILE__, line = __LINE__) : NoReturn
  LibC.dprintf(2, "abort: %s at %s:%d\n", message, file, line)
  LibC.exit(1)
end

# Prints a message on STDERR, followed by a backtrace, then terminates the
# current thread. If the current thread is the main thread, then the program
# will exit with an error status.
def panic!(format, *args) : NoReturn
  unless Nano.silenced_panic?
    LibC.dprintf(2, "panic: ")
    LibC.dprintf(2, format, *args)
    LibC.dprintf(2, "\n")

    unwind_stack do |ip|
      # TODO: search in debug section first (i.e. DWARF)
      if frame = decode_frame(ip)
        offset, symbol, file = frame
        symbol ||= "??".to_unsafe
        file ||= "??".to_unsafe
        LibC.dprintf(2, "  [0x%lx] %s +%lld in %s\n", ip, symbol, offset, file)
      else
        LibC.dprintf(2, "  [0x%lx] ???\n", ip)
      end
    end
  end

  if Nano.main_thread?
    LibC.exit(1)
  else
    LibC.pthread_exit(Pointer(Void).new(1))
  end
end

def unreachable! : NoReturn
  panic! "unreachable statement has been reached (oops)"
end

# :nodoc:
fun __crystal_raise_overflow : NoReturn
  panic! "overflow error"
end

private def unwind_stack(&block : Void* -> Nil) : Nil
  boxed = Box.new(block)

  callback = ->(context : LibUnwind::Context, data : Void*) do
    ip =
      {% if flag?(:arm) %}
        __crystal_unwind_get_ip(context)
      {% else %}
        LibUnwind.get_ip(context)
      {% end %}

    proc = Box(typeof(block)).unbox(data)
    proc.call Pointer(Void).new(ip)

    LibUnwind::ReasonCode::NO_REASON
  end

  LibUnwind.backtrace(callback, pointerof(boxed))
end

private def decode_frame(ip : Void*, original_ip : Void* = ip) : {Int64, UInt8*, UInt8*}?
  return if LibC.dladdr(ip, out info) == 0

  offset = original_ip - info.dli_saddr
  return decode_frame(ip - 1, original_ip) if offset == 0
  return if info.dli_sname.null? && info.dli_fname.null?

  {offset, info.dli_sname, info.dli_fname}
end
