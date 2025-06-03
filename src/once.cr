fun __crystal_once(flag : Bool*, initializer : Void*)
  return if flag.value

  flag.value = true
  Proc(Nil).new(initializer, Pointer(Void).null)

  unless flag.value
    # Intrinsics.unreachable
    x = uninitialized NoReturn
    x
  end
end
