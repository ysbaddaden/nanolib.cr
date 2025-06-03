require "c/pthread"

lib LibC
  {% if flag?(:darwin) || flag?(:bsd) %}
    fun pthread_main_np : Int
  {% end %}
  fun pthread_exit(Void*) : NoReturn
end

struct Nano::Thread
  {% if !LibC.has_method?(:pthread_main_np) %}
    @@main_handle = LibC.pthread_self
  {% end %}

  @[AlwaysInline]
  def self.main? : Bool
    {% if LibC.has_method?(:pthread_main_np) %}
      LibC.pthread_main_np == 1
    {% else %}
      @@main_handle == LibC.pthread_self
    {% end %}
  end

  @[AlwaysInline]
  def self.current : self
    new(LibC.pthread_self)
  end

  def self.create(proc : Proc(Nil)) : self
    if proc.closure_data
      panic! "passing a closure to C is not allowed"
    end

    start = ->(proc_ : Void*) {
      Proc(Nil).new(proc_, Pointer(Void).null).call
      LibC.pthread_detach(LibC.pthread_self)
      Pointer(Void).null
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

      LibC.pthread_detach(LibC.pthread_self)
      Pointer(Void).null
    }
    create_impl(start, box.as(Void*))
  end

  private def self.create_impl(start : Proc(Void*, Void*), data : Void*) : self
    err = LibC.pthread_create(out id, nil, start, data.as(Void*))
    errno!("pthread_create", -err) if err < 0
    new(id)
  end

  @[AlwaysInline]
  def self.exit(retval : Int32) : Nil
    LibC.pthread_exit(Pointer(Void).new(retval.to_u64!))
  end

  def initialize(@id : LibC::PthreadT)
  end

  def join : Nil
    err = LibC.pthread_join(@id, out _)
    errno!("pthread_join", err) if err < 0
  end

  def detach : Nil
    err = LibC.pthread_detach(@id)
    errno!("pthread_detach", err) if err < 0
  end

  def to_unsafe : LibC::PthreadT
    @id
  end
end
