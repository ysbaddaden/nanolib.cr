abstract struct Nano::Test
  enum Status
    SKIP
    FAILURE
    SUCCESS
  end

  struct Result
    def initialize(@suite_name : String, @method_name : String)
      @status = Status::SUCCESS
      @duration = 0.0
    end

    def suite_name : String
      @suite_name
    end

    def method_name : String
      @method_name
    end

    def duration : Float64
      @duration
    end

    def duration=(value : Float64)
      @duration = value
    end

    def status : Status
      @status
    end

    def status=(status : Status)
      @status = status
    end

    def status=(_status)
      @status = Status::SUCCESS
    end

    def failed? : Bool
      @status == Status::FAILURE
    end

    def skipped? : Bool
      @status == Status::SKIP
    end

    def success? : Bool
      @status == Status::SUCCESS
    end
  end
end
