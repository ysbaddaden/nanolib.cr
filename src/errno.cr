require "lib_c"
require "c/errno"
require "c/string"
require "./panic"

lib LibC
  # FIXME: these should be in c/errno!
  {% if flag?(:linux) || flag?(:dragonfly) %}
    fun __errno_location : Int*
  {% elsif flag?(:wasi) %}
    $errno : Int
  {% elsif flag?(:darwin) || flag?(:freebsd) %}
    fun __error : Int*
  {% elsif flag?(:netbsd) || flag?(:openbsd) %}
    fun __error = __errno : Int*
  {% elsif flag?(:win32) %}
    fun _get_errno(value : Int*) : ErrnoT
    fun _set_errno(value : Int) : ErrnoT
  {% end %}
end

@[AlwaysInline]
def errno : Int32
  {% if flag?(:linux) || flag?(:dragonfly) %}
    LibC.__errno_location.value
  {% elsif flag?(:darwin) || flag?(:bsd) %}
    LibC.__error.value
  {% elsif flag?(:win32) %}
    ret = LibC._get_errno(out errno)
    panic! "_get_errno failed" unless ret == 0
    errno
  {% end %}
end

def errno!(function_name : String, errnum = errno) : NoReturn
  # FIXME: strerror isn't thread-safe, use strerror_r instead!
  # errmsg = UInt8[256]
  # errmsg[-1] = 0 if LibC.strerror_r(errnum, errmsg, LibC::SizeT.new(errmsg.bytesize)) == -1
  errmsg = LibC.strerror(errnum)
  panic! "%s failed with %s (errno=%d)", function_name, errmsg, errnum
end
