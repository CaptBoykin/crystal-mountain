require "option_parser"

upcase = false
destination = "World"

OptionParser.parse! do |parser|
  parser.banner = "Usage: salute [arguments]"
  parser.on("-u", "--upcase", "Upcases the salute") { upcase = true }
  parser.on("-t NAME", "--to=NAME", "Specifies the name to salute") { |name| destination = name }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

destination = destination.upcase if upcase
puts "Hello #{destination}!"
