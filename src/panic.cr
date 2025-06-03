require "./nano/thread"
require "./nano/print_error"
require "./nano/unwind"

module Nano
  # FIXME: OpenBSD and older Android NDK don't support @[ThreadLocal]
  {% unless flag?(:wasi) %} @[ThreadLocal] {% end %}
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
  Nano.print_error("abort: %s at %s:%d\n", message, file, line)
  Nano.exit(1)
end

# Prints a message on STDERR, followed by a backtrace, then terminates the
# current thread. If the current thread is the main thread, then the program
# will exit with an error status.
@[NoInline]
def panic!(format, *args) : NoReturn
  # {% if flag?(:debug) %} debugger {% end %}

  unless Nano.silenced_panic?
    Nano.print_error("panic: ")
    Nano.print_error(format, *args)
    Nano.print_error("\n")

    Nano.unwind_stack do |ip|
      if frame = Nano.decode_frame(ip)
        offset, symbol, file = frame
        symbol ||= "??".to_unsafe
        file ||= "??".to_unsafe
        Nano.print_error("  [0x%lx] %s +%lld in %s\n", ip, symbol, offset, file)
      else
        Nano.print_error("  [0x%lx] ???\n", ip)
      end
    end
  end

  if Nano::Thread.main?
    Nano.exit(1)
  else
    Nano::Thread.exit(1)
  end
end

def unreachable! : NoReturn
  panic! "unreachable statement has been reached (oops)"
end
