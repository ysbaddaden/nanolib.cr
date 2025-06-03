# def Nano.exit(status : Int32) : NoReturn

{% if flag?(:avr) %}
  require "./sys/avr"
{% elsif flag?(:wasi) %}
  require "./sys/wasi"
{% elsif flag?(:win32) %}
  require "./sys/win32"
{% else %}
  require "./sys/unix"
{% end %}
