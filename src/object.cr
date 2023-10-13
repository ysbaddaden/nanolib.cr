class Object
  @[AlwaysInline]
  def ===(other)
    self == other
  end

  @[AlwaysInline]
  def unsafe_as(type : F.class) : F forall F
    x = self
    pointerof(x).as(F*).value
  end

  @[AlwaysInline]
  def tap(&block : self ->) : self
    yield self
    self
  end

  @[AlwaysInline]
  def try(&block : self -> F) : F forall F
    yield self
  end

  @[AlwaysInline]
  def not_nil!(message : String? = nil) : self
    self
  end

  macro getter(typedef)
    {% raise "macro getter expects a typedef" unless typedef.is_a?(TypeDeclaration) %}

    @{{typedef.var.id}} : {{typedef.type}}

    @[AlwaysInline]
    def {{typedef.var.id}} : {{typedef.type}}
      @{{typedef.var.id}}
    end
  end

  macro setter(typedef)
    {% raise "macro setter expects a typedef" unless typedef.is_a?(TypeDeclaration) %}

    @{{typedef.var.id}} : {{typedef.type}}

    @[AlwaysInline]
    def {{typedef.var.id}}=(value : {{typedef.type}}) : {{typedef.type}}
      @{{typedef.var.id}} = value
    end
  end

  macro property(typedef)
    {% raise "macro property expects a typedef" unless typedef.is_a?(TypeDeclaration) %}

    @{{typedef.var.id}} : {{typedef.type}}

    @[AlwaysInline]
    def {{typedef.var.id}} : {{typedef.type}}
      @{{typedef.var.id}}
    end

    @[AlwaysInline]
    def {{typedef.var.id}}=(value : {{typedef.type}}) : {{typedef.type}}
      @{{typedef.var.id}} = value
    end
  end
end
