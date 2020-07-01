require "socket"
require "./auth"
client = TCPSocket.new("127.0.0.1", 9999)
content = File.open("myagent_cookie") do |file|
file.gets_to_end
end
client << "#{content}\r\n"
response = client.gets
client.close
