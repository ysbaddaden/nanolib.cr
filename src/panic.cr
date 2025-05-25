require "c/stdio"
require "c/stdlib"
{% if flag?(:win32) %}
  require "c/fileapi"
  require "c/processenv"
  require "c/winbase"
{% else %}
  require "c/dlfcn"
  require "exception/lib_unwind"
  require "./box"
{% end %}
require "./nano/thread"

module Nano
  {% if flag?(:win32) %}
    def self.print_error(message : String, *args) : Nil
      if args.empty?
        LibC.WriteFile(LibC.GetStdHandle(LibC::STD_ERROR_HANDLE), message.to_unsafe, message.bytesize, out _, nil)
      else
        __snprintf(message, *args) do |ptr, size|
          LibC.WriteFile(LibC.GetStdHandle(LibC::STD_ERROR_HANDLE), ptr, size, out _, nil)
        end
      end
    end

    # :nodoc:
    private def self.__snprintf(message : String, *args, &)
      buffer = uninitialized UInt8[512]
      size = LibC.snprintf(buffer.to_unsafe, buffer.size, message, *args)
      if size > buffer.size
        ptr = LibC.malloc(size &+ 1).as(UInt8*)
        size = LibC.snprintf(buffer.to_unsafe, size, message, *args)
        yield ptr, size
        LibC.free(ptr)
      else
        yield buffer.to_unsafe, size
      end
    end
  {% else %}
    def self.print_error(message : String, *args) : Nil
      LibC.dprintf(2, message, *args)
    end

    def self.unwind_stack(&block : Void* -> Nil) : Nil
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

    def self.decode_frame(ip : Void*, original_ip : Void* = ip) : {Int64, UInt8*, UInt8*}?
      return if LibC.dladdr(ip, out info) == 0

      offset = original_ip - info.dli_saddr
      return decode_frame(ip - 1, original_ip) if offset == 0
      return if info.dli_sname.null? && info.dli_fname.null?

      {offset, info.dli_sname, info.dli_fname}
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
  Nano.print_error("abort: %s at %s:%d\n", message, file, line)
  LibC.exit(1)
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

    {% if flag?(:win32) %}
      # TODO: unwind stack on windows
    {% else %}
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
    {% end %}
  end

  if Nano::Thread.main?
    LibC.exit(1)
  else
    Nano::Thread.exit(1)
  end
end

def unreachable! : NoReturn
  panic! "unreachable statement has been reached (oops)"
end
