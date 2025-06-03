require "c/stdio"

{% if flag?(:win32) %}
  require "c/fileapi"
  require "c/processenv"
  require "c/winbase"
  require "c/stdlib"
{% end %}

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
  {% end %}
end
