require "../src/nano"
require "../src/test"

struct Nano::Test
  macro assert_panic
    {% if flag?(:wasi) %}
      skip
    {% else %}
      completed = false

      thread = Nano::Thread.create(->(completed : Bool*) {
        Nano.silenced_panic = true
        {{yield}}
        completed.value = true
      }, pointerof(completed))
      thread.join

      refute completed
    {% end %}
  end
end
