# NOTE: WASI has an extension to create threads, though it's not necessarily
# available in runtimes; it also has nothing to early exit threads (must exit
# process on panic).

struct Nano::Thread
  def self.main? : Bool
    true
  end

  def self.current : self
    Thread.new
  end

  def self.exit(retval : Int32) : NoReturn
    LibWASI.proc_exit(retval)
  end

  def to_unsafe : Nil
  end
end
