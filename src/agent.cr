require "socket"
#require "./auth"
stdout = IO::Memory.new
connfd = TCPServer.new("127.0.0.1", 12345)
#content = File.open("#{cookie_file}") do |file|
#       file.gets_to_end
#end
#connfd << content#

def handle_master(master)
      puts "master connected.\n"
      message = `#{master.gets.to_s}`
      puts message
      master.puts(message)
end

while master = connfd.accept?
      spawn handle_master(master)
end
