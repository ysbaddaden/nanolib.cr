require "c/errno"
require "c/string"
require "./panic"

lib LibC
  # FIXME: these should be in c/errno!
  {% if flag?(:linux) || flag?(:dragonfly) %}
    fun errno = __errno_location : Int*
  {% elsif flag?(:darwin) || flag?(:freebsd) %}
    fun errno = __error : Int*
  {% elsif flag?(:netbsd) || flag?(:openbsd) %}
    fun errno = __errno : Int*
  {% elsif flag?(:wasi) %}
    $errno : Int
  {% elsif flag?(:win32) %}
    fun _get_errno(value : Int*) : ErrnoT
    # fun _set_errno(value : Int) : ErrnoT
  {% end %}
end

@[AlwaysInline]
def errno : Int32
  {% if flag?(:win32) %}
    ret = LibC._get_errno(out errno)
    panic! "_get_errno failed" unless ret == 0
    errno
  {% elsif flag?(:wasi) %}
    LibC.errno
  {% else %}
    LibC.errno.value
  {% end %}
end

@[NoInline]
def errno!(function_name : String, errnum = errno) : NoReturn
  # FIXME: strerror isn't thread-safe, use strerror_r instead!
  # errmsg = UInt8[256]
  # errmsg[-1] = 0 if LibC.strerror_r(errnum, errmsg, LibC::SizeT.new(errmsg.bytesize)) == -1
  errmsg = LibC.strerror(errnum)
  panic! "%s failed with %s (errno=%d)", function_name, errmsg, errnum
end
