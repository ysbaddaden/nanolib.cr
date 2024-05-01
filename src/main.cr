{% if flag?(:win32) %}
  @[Link({{ flag?(:static) ? "libcmt" : "msvcrt" }})] # For `mainCRTStartup`
{% end %}
lib LibCrystalMain
  @[Raises]
  fun __crystal_main(argc : Int32, argv : UInt8**)
end

{% if flag?(:avr) %}
  fun main : Void
    LibCrystalMain.__crystal_main(0, Pointer(UInt8).null)
  end
{% else %}
  fun main(argc : Int32, argv : UInt8**) : Int32
    LibCrystalMain.__crystal_main(argc, argv)
    0
  end
{% end %}
