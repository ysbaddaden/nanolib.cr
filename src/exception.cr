# The crystal compiler expects the `raise` methods to exist at different
# places. We treat them as mere calls to `panic!`.
#
# For example:
#
# - `raise(String)` is expected by a runtime check to verify that a proc isn't a
#   closure when trying to pass it to a C function (among other cases);
# - `raise(TypeCastError)` is required when trying to cast from an union to a
#   specific value (it raises on failure);
# - `raise(IndexError)` can happen in an expanded multiple assignment.

# :nodoc:
struct TypeCastError
  def initialize(@message : String)
  end
end

# :nodoc:
struct IndexError
  def initialize(@message : String)
  end
end

# :nodoc:
def raise(ex : TypeCastError | IndexError) : NoReturn
  panic! ex.@message
end

# :nodoc:
def raise(message : String) : NoReturn
  panic! message
end

# :nodoc:
fun __crystal_raise_overflow : NoReturn
  panic! "overflow error"
end
