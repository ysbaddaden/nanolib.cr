require "c/handleapi"
require "c/process"
require "c/processthreadsapi"
require "c/synchapi"

lib LibC
  fun _endthreadex(LibC::UInt) : NoReturn
end

struct Nano::Thread
  @@main_handle = LibC.GetCurrentThread

  @[AlwaysInline]
  def self.main? : Bool
    @@main_handle == LibC.GetCurrentThread
  end

  @[AlwaysInline]
  def self.current : self
    new LibC.GetCurrentThread
  end

  def self.create(proc : Proc(Nil)) : self
    if proc.closure_data
      panic! "passing a closure to C is not allowed"
    end

    start = ->(proc_ : Void*) {
      Proc(Nil).new(proc_, Pointer(Void).null).call
      LibC.CloseHandle(LibC.GetCurrentThread)
      0_u32
    }
    create_impl(start, proc.pointer)
  end

  def self.create(proc : Proc(F, Nil), arg : F) : self forall F
    if proc.closure_data
      panic! "passing a closure to C is not allowed"
    end

    box = Box({Proc(F, Nil), F}).malloc({proc, arg})

    start = ->(box_ : Void*) {
      proc_, arg_ = Box({Proc(F, Nil), F}).unbox(box_)
      LibC.free(box_)

      proc_.call(arg_)

      LibC.CloseHandle(LibC.GetCurrentThread)
      0_u32
    }
    create_impl(start, box.as(Void*))
  end

  private def self.create_impl(start : Proc(Void*, UInt32), data : Void*) : self
    handle = LibC._beginthreadex(nil, 0, start, data, 0, nil)
    errno!("_beginthreadex") if handle == LibC::INVALID_HANDLE_VALUE
    new(handle)
  end

  @[AlwaysInline]
  def self.exit(retval : Int32) : Nil
    LibC._endthreadex(retval.to_u32!)
  end

  def initialize(@id : LibC::HANDLE)
  end

  def join : Nil
    ret = LibC.WaitForSingleObject(@id, LibC::INFINITE)
    winerror!("WaitForSingleObject") unless ret == LibC::WAIT_OBJECT_0
  end

  def detach : Nil
    ret = LibC.CloseHandle(@id)
    winerror!("CloseHandle") unless ret == 0
  end

  def to_unsafe : LibC::HANDLE
  end
end
