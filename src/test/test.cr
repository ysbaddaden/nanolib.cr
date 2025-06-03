require "c/stdlib"
require "../nano"
require "../nano/print_error"
require "./autorun"
require "./options"
require "./result"
require "./test"

abstract struct Nano::Test
  @@count = 0
  @@failures = 0
  @@skips = 0
  @@total_duration = 0.0
  @@options = Options.new

  def self.count
    @@count
  end

  protected def self.count=(value : Int32)
    @@count = value
  end

  def self.failures
    @@failures
  end

  def self.skips
    @@skips
  end

  def self.total_duration
    @@total_duration
  end

  def self.configure(& : Pointer(Options) ->) : Nil
    yield pointerof(@@options)
  end

  def self.failed?
    @@failures > 0
  end

  def self.status
    if failed?
      Status::FAILURE
    else
      Status::SUCCESS
    end
  end

  def self.run : Bool
    {% for suite in Nano::Test.all_subclasses %}
      {{ suite.name }}.run_suite
    {% end %}

    if @@options.verbose?
      Nano.print_error("\n")
    else
      Nano.print_error("\n\n")
    end

    color, reset = colors(status)

    Nano.print_error("Finished in %s\n", humanize(total_duration))
    Nano.print_error("%s%d runs, %d failures, %d skips%s\n", color, count, failures, skips, reset)

    !failed?
  end

  protected def self.measure : Float64?
    start = Nano.clock_monotonic
    yield
    stop = Nano.clock_monotonic
    (stop[0] &- start[0]).to_f + (stop[1] &- start[1]).to_f / 1_000_000_000.0
  end

  protected def self.report(result : Result) : Nil
    case result.status
    when Status::FAILURE
      @@failures &+= 1
      char = "F"
    when Status::SKIP
      @@skips &+= 1
      char = "S"
    when Status::SUCCESS
      char = "."
    else
      unreachable!
    end

    @@total_duration += result.duration
    color, reset = colors(result.status)

    if @@options.verbose?
      Nano.print_error("%s#%s (%s) = %s%s%s\n", result.suite_name, result.method_name, humanize(result.duration), color, char, reset)
    else
      Nano.print_error("%s%s%s", color, char, reset)
    end
  end

  private def self.colors(status)
    if @@options.colorful?
      color =
        case status
        when Status::SUCCESS then "\e[32m"
        when Status::FAILURE then "\e[31m"
        when Status::SKIP    then "\e[33m"
        else unreachable!
        end
      {color, "\e[0m"}
    else
      {"", ""}
    end
  end

  @[AlwaysInline]
  private def self.humanize(duration : Float64)
    if duration < 0.000_001
      format = "%.f ns"
      duration *= 1_000_000_000
    elsif duration < 0.001
      format = "%.3f us"
      duration *= 1_000_000
    elsif duration < 1.0
      format = "%.3f ms"
      duration *= 1_000
    else
      format = "%.3f s"
    end

    str = uninitialized UInt8[20]
    LibC.snprintf(str, 20, format, duration)
    str
  end

  def self.run_suite : Nil
    {% for method in @type.methods %}
      {% if method.name.starts_with?("test_") %}
        Test.count &+= 1

        result = Test::Result.new({{@type.name.stringify}}, {{method.name.stringify}})
        %test = new

        result.duration = Test.measure do
          %test.setup
          result.status = (%test.{{method.name}})
          %test.teardown
        end

        Test.report(result)
      {% end %}
    {% end %}
  end

  def setup : Nil
  end

  def teardown : Nil
  end

  macro skip
    return ::Nano::Test::Status::SKIP
  end

  macro flunk
    return ::Nano::Test::Status::FAILURE
  end

  macro assert(expression, file = __FILE__, line = __LINE__)
    if !!({{expression}}) == false
      Nano.print_error("Expected %s to be truthy\n", {{expression.stringify}})
      Nano.print_error("  at %s:%d\n", {{file}}, {{line}})
      return ::Nano::Test::Status::FAILURE
    end
  end

  macro refute(expression, file = __FILE__, line = __LINE__)
    if !!({{expression}}) == true
      Nano.print_error("Expected %s to be falsy\n", {{expression.stringify}})
      Nano.print_error("  at %s:%d\n", {{file}}, {{line}})
      return ::Nano::Test::Status::FAILURE
    end
  end
end
