lib LibWASM
  fun __wasm_call_ctors
  fun __wasm_call_dtors
  fun __main_void : Int32
end

lib LibWASI
  CLOCKID_REALTIME = 0_u32
  CLOCKID_MONOTONIC = 1_u32

  alias ErrnoT = UInt16

  fun proc_exit = __wasi_proc_exit(Int32) : NoReturn
  fun clock_time_get = __wasi_clock_time_get(UInt32, UInt64, UInt64*) : ErrnoT
end

module Nano
  def self.exit(status : Int32) : NoReturn
    LibWASI.proc_exit(status)
  end

  def self.clock_monotonic : {Int64, Int32}
    LibWASI.clock_time_get(LibWASI::CLOCKID_MONOTONIC, 0, out now)
    seconds = (now // 1_000_000_000).to_i64!
    nanoseconds = now.remainder(1_000_000_000).to_i32!
    {seconds, nanoseconds}
  end
end
