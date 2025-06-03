struct Nano::Thread
  def self.main? : Bool
    {% raise "Not Implemented: Nano::Thread.main?" %}
  end

  def self.current : self
    {% raise "Not Implemented: Nano::Thread.current" %}
  end

  # Starts a new thread to execute *proc*.
  #
  # NOTE: *proc* cannot closure variables.
  def self.create(proc : Proc(Nil)) : self
    {% raise "Not Implemented: Nano::Thread.create(proc)" %}
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
    {% raise "Not Implemented: Nano::Thread.create(proc, arg)" %}
  end

  def self.exit(retval : Int32) : NoReturn
    {% raise "Not Implemented: Nano::Thread.exit(retval)" %}
  end

  def join : Nil
    {% raise "Not Implemented: Nano::Thread#join" %}
  end

  def detach : Nil
    {% raise "Not Implemented: Nano::Thread#detach" %}
  end

  def to_unsafe
    {% raise "Not Implemented: Nano::Thread#to_unsafe" %}
  end
end

{% if flag?(:avr) %}
  # skip
{% elsif flag?(:wasi) %}
  require "../sys/thread/wasi"
{% elsif flag?(:win32) %}
  require "../sys/thread/win32"
{% else %}
  require "../sys/thread/unix"
{% end %}
