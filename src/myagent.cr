require "socket"
require "./auth.cr"
stdout = IO::Memory.new
connfd = TCPSocket.new("127.0.0.1", 9999)
content = File.open("myagent_cookie") do |file|
	file.gets_to_end
end
connfd << content
while true
	output = `#{connfd.gets.to_s}`
	connfd << output
end
