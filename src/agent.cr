require "socket"
require "./auth"

client = TCPSocket.new("localhost", 12345)

content = File.open("./cookie") do |file|
	file.gets_to_end
end

client << "#{content}\r\n"
response = client.gets
client.close
