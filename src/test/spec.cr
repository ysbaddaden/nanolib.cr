macro describe(name)
  struct {{name.id.stringify.camelcase.id}}Spec < Nano::Spec
    {{yield}}
  end
end

abstract struct Nano::Spec < Nano::Test
  macro let(name)
    {% name = name.id.stringify.gsub(/[^\w\d_]+/, "_").id %}
    def {{name}}
      @{{name}} ||= begin; {{ yield }}; end
    end
  end

  macro before
    def setup
      {{yield}}
      super()
    end
  end

  macro after
    def teardown
      {{yield}}
      super()
    end
  end

  macro describe(name)
    {% raise "ERROR: can't nest spec contexts (can't inherit from non abstract struct)" %}
  end

  macro it(name)
    def test_{{name.id.stringify.gsub(/[^\w\d_]+/, "_").id}}
      {{yield}}
    end
  end
end
