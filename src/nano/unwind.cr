{% unless flag?(:win32) || flag?(:wasi) %}
  require "c/dlfcn"
  require "exception/lib_unwind"
  require "../box"
{% end %}

module Nano
  {% begin %}
  def self.unwind_stack(&block : Void* -> Nil) : Nil
    {% unless flag?(:win32) || flag?(:wasi) %}
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
    {% end %}
  end

  def self.decode_frame(ip : Void*, original_ip : Void* = ip) : {Int64, UInt8*, UInt8*}?
    {% unless flag?(:win32) || flag?(:wasi) %}
      return if LibC.dladdr(ip, out info) == 0

      offset = original_ip - info.dli_saddr
      return decode_frame(ip - 1, original_ip) if offset == 0
      return if info.dli_sname.null? && info.dli_fname.null?

      {offset, info.dli_sname, info.dli_fname}
    {% end %}
  end
  {% end %}
end
