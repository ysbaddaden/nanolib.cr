require "../src/nano"
require "../src/test"

struct Nano::Test
  macro assert_panic
    %start_routine = ->(data : Void*) do
      Nano.silenced_panic = true
      {{yield}}
      Pointer(Void).null
    end

    %errnum = LibC.pthread_create(out %th, nil, %start_routine, nil)
    panic! "pthread_create(3) failed" unless %errnum == 0

    %errnum = LibC.pthread_join(%th, out %retval)
    panic! "pthread_join(3) failed" unless %errnum == 0

    refute %retval.null?
  end
end
