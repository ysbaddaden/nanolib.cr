fun __crystal_once(flag : Bool*, initializer : Void*)
  return if flag.value

  flag.value = true
  Proc(Nil).new(initializer, Pointer(Void).null)

  Intrinsics.unreachable unless flag.value
end
