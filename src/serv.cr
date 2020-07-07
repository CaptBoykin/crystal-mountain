require "socket"

module MtMaster

	extend self

	def init_server(addr : String, port : Int32) : (TCPServer|Bool)
		return TCPServer.new(addr, port)	
	end

	def run_server(server : TCPServer) : (Bool|Nil)
		while true
			server.accept do |client|
					proc = Process.fork do
						rhost = client.remote_address()
						lhost = client.local_address()
	
						puts "[*] connection from #{rhost} -> #{lhost}"
						#message = client.gets
						#input = gets
						#client << input
					end
				
				proc.wait	
				client.close
				end
			end
		return
	end
end
