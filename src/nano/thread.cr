{% if flag?(:win32) %}
  require "c/process"
  require "c/processthreadsapi"

  lib LibC
    fun _endthreadex(LibC::UInt) : NoReturn
  end
end
{% else %}
  require "c/pthread"
  require "c/sched"

  lib LibC
    {% if flag?(:darwin) || flag?(:bsd) %}
      fun pthread_main_np : Int
    {% end %}
    fun pthread_exit(Void*) : NoReturn
  end
{% end %}

struct Nano::Thread
  {% if flag?(:win32) %}
    @@main_handle = LibC.GetCurrentThread
  {% elsif !LibC.has_method?(:pthread_main_np) %}
    @@main_handle = LibC.pthread_self
  {% end %}

  @[AlwaysInline]
  def self.main? : Bool
    {% if LibC.has_method?(:pthread_main_np) %}
      LibC.pthread_main_np == 1
    {% elsif flag?(:win32) %}
      @@main_handle == LibC.GetCurrentThread
    {% else %}
      @@main_handle == LibC.pthread_self
    {% end %}
  end

  @[AlwaysInline]
  def self.current : self
    {% if flag?(:win32) %}
      new(LibC.GetCurrentThread)
    {% else %}
      new(LibC.pthread_self)
    {% end %}
  end

  # Starts a new thread to execute *proc*.
  #
  # NOTE: *proc* cannot closure variables.
  def self.create(proc : Proc(Nil)) : self
    if proc.closure_data
      panic! "passing a closure to C is not allowed"
    end

    start = ->(proc_ : Void*) {
      Proc(Nil).new(proc_, Pointer(Void).null).call

      {% if flag?(:win32) %}
        LibC.CloseHandle(LibC.GetCurrentThread)
        0_u32
      {% else %}
        LibC.pthread_detach(LibC.pthread_self)
        Pointer(Void).null
      {% end %}
    }
    create_impl(start, proc.pointer)
  end

  # Starts a new thread to execute *proc*, and pass an explicit argument. The
  # argument is transparently passed through the HEAP and automatically freed
  # once the thread has started.
  #
  # ```
  # thread = Nano::Thread.create(->(value : Int32) {
  #   LibC.printf("value=%d\n", value)
  # }, 123)
  # thread.join
  # ```
  #
  # You can pass multiple arguments by passing a `Tuple`:
  #
  # ```
  # thread = Nano::Thread.create(->(args : {Int32, Int32}) {
  #   LibC.printf("a=%d b=%d\n", *args)
  # }, {123, 456})
  # thread.join
  # ```
  #
  # NOTE: *proc* cannot closure variables.
  def self.create(proc : Proc(F, Nil), arg : F) : self forall F
    if proc.closure_data
      panic! "passing a closure to C is not allowed"
    end

    box = Box({Proc(F, Nil), F}).malloc({proc, arg})

    start = ->(box_ : Void*) {
      proc_, arg_ = Box({Proc(F, Nil), F}).unbox(box_)
      LibC.free(box_)

      proc_.call(arg_)

      {% if flag?(:win32) %}
        LibC.CloseHandle(LibC.GetCurrentThread)
        0_u32
      {% else %}
        LibC.pthread_detach(LibC.pthread_self)
        Pointer(Void).null
      {% end %}
    }
    create_impl(start, box.as(Void*))
  end

  {% if flag?(:win32) %}
    private def self.create_impl(start : Proc(Void*, UInt32), data : Void*) : self
      handle = _beginthreadex(nil, 0, start, data, 0, nil)
      errno!("_beginthreadex") if handle == 0
      new(LibC::HANDLE.new(handle))
    end
  {% else %}
    private def self.create_impl(start : Proc(Void*, Void*), data : Void*) : self
      err = LibC.pthread_create(out id, nil, start, data.as(Void*))
      errno!("pthread_create", -err) if err < 0
      new(id)
    end
  {% end %}

  @[AlwaysInline]
  def self.exit(retval : Int32) : Nil
    {% if flag?(:win32) %}
      LibC._endthreadex(retval.to_u32!)
    {% else %}
      LibC.pthread_exit(Pointer(Void).new(retval.to_u64!))
    {% end %}
  end

  {% if flag?(:win32) %}
    @id : LibC::HANDLE
  {% else %}
    @id : LibC::PthreadT
  {% end %}

  def initialize(@id)
  end

  def join : Nil
    {% if flag?(:win32) %}
      ret = LibC.WaitForSingleObject(@id, LibC::INFINITE)
      winerror!("WaitForSingleObject") unless ret == LibC::WAIT_OBJECT_0
    {% else %}
      err = LibC.pthread_join(@id, out _)
      errno!("pthread_join", err) if err < 0
    {% end %}
  end

  def detach : Nil
    {% if flag?(:win32) %}
      ret = LibC.CloseHandle(@id)
      winerror!("CloseHandle") unless ret == 0
    {% else %}
      err = LibC.pthread_detach(@id)
      errno!("pthread_detach", err) if err < 0
    {% end %}
  end
end
