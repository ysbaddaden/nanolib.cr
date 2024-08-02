abstract struct Nano::Test
  struct Options
    def initialize(@verbose = false, @colorful = true)
    end

    def verbose?
      @@verbose
    end

    def verbose=(value : Bool)
      @@verbose = value
    end

    def colorful?
      @colorful
    end

    def colorful=(value : Bool)
      @colorful = value
    end
  end
end
