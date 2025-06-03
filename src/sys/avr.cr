module Nano
  def self.exit(status : Int32)
    # can't exit: enter busy loop
    while true; end
  end
end
