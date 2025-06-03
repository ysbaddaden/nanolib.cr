require "./test"
require "../argv"

Nano::Test.configure do |options|
  ARGV.each do |arg|
    case arg
    when "-v", "--verbose"
      options.value.verbose = true
    when "--no-color"
      options.value.colorful = false
    end
  end
end

success = Nano::Test.run
Nano.exit(success ? 0 : 1)
