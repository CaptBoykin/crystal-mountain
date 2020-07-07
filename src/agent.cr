require "socket"
require "./auth.cr"

stdout = IO::Memory.new
connfd = TCPSocket.new("127.0.0.1",12345)

userinput = confd.gets.to_s.split(' ')
process = Process.new(userinput[0],[userinput[1]], output: stdout)
status - process.wait
connfd << stdout.to_s
