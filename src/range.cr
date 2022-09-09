struct Range(B, E)
  def begin : B
    @begin
  end

  def end : E
    @end
  end

  def exclusive? : Bool
    @exclusive
  end

  def initialize(@begin : B, @end : E, @exclusive : Bool = false)
  end

  def ==(other : Range)
    @begin == other.@begin &&
      @end == other.@end &&
      @exclusive == other.@exclusive
  end

  def each : Nil
    {% if B == Nil %}{% raise "can't each beginless range" %}{% end %}

    current = @begin
    panic! "can't each beginless range" if current.nil?

    {% if E == Nil %}
      while true
        yield current
        current = current.succ
      end
    {% else %}
      end_value = @end
      while end_value.nil? || current < end_value
        yield current
        current = current.succ
      end
      yield current if !@exclusive && current == end_value
    {% end %}
  end

  def reverse_each : Nil
    {% if E == Nil %}{% raise "can't reverse_each endless range" %}{% end %}

    end_value = @end
    panic! "can't reverse_each endless range" if end_value.nil?

    begin_value = @begin

    yield end_value if !@exclusive && (begin_value.nil? || !(end_value < begin_value))
    current = end_value

    {% if B == Nil %}
      while true
        current = current.pred
        yield current
      end
    {% else %}
      while begin_value.nil? || begin_value < current
        current = current.pred
        yield current
      end
    {% end %}
  end

  # def includes?(value) : Bool
  #   (begin_value.nil? || value >= begin_value) &&
  #     (end_value.nil? ||
  #       (@exclusive ? value < end_value : value <= end_value))
  # end
end
