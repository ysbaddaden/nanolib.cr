require "c/winbase"
require "c/errhandlingapi"
require "./panic"

def winerror!(function_name : String, errnum = LibC.GetLastError) : NoReturn
  flags = LibC::FORMAT_MESSAGE_FROM_SYSTEM | LibC::FORMAT_MESSAGE_ALLOCATE_BUFFER

  if LibC.FormatMessageA(flags, nil, errnum, 0, out buffer, 256, nil) != 0
    panic! "%s failed with %s (winerror=%d)", function_name, buffer, errnum
    # FIXME: buffer is leaked when panic only terminates the current thread
    # LibC.LocalFree(buffer.as(Void*))
  else
    panic! "%s failed with %s (winerror=%d)", function_name, "unknown error", errnum
  end
end
