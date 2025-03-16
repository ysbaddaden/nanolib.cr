struct Tuple
  def self.types
    Tuple.new(*{{T}})
  end

  def first
    self[0]
  end

  def first?
    {% if T.size > 0 %}
      self[0]
    {% end %}
  end

  def last
    {% begin %}
      self[{{T.size - 1}}]
    {% end %}
  end

  def last?
    {% if T.size > 0 %}
      self[{{T.size - 1}}]
    {% end %}
  end

  def size : Int32
    {{T.size}}
  end
end
