require "socket"
require "./auth.cr"


module AGENT

	extend self
	
	def agent_create(agentname : String,  rhost : String, rport : Int32, cookie_file : String) : (Bool|Nil)
		
		File.open("#{agentname}.cr", "w") do |fp|
			fp.puts "require \"socket\""
			fp.puts "require \"./auth\""
			fp.puts "client = TCPSocket.new(\"#{rhost}\", #{rport})"
			fp.puts "content = File.open(\"#{cookie_file}\") do |file|"
			fp.puts	"file.gets_to_end"
			fp.puts "end"
			fp.puts "client << \"\#{content}\\r\\n\""
			fp.puts "response = client.gets"
			fp.puts "client.close"
		end

		
		system("/usr/bin/crystal build #{Dir.current}/#{agentname}.cr")
	end


	def create_cookie_file(cookie_file : String, lhost : String)
		
		token = AUTH.generate_token(lhost)
		token_enc = AUTH.generate_cookie(token)

		File.open("#{cookie_file}","w") do |fp|
			fp.puts token_enc
		end
	end

end



module MASTER

	extend self

	def init_server(addr : String, port : Int32) : (TCPServer|Bool)
		return TCPServer.new(addr, port)	
	end

	def run_server(server : TCPServer) : (Bool|Nil)
		while true
			server.accept do |client|
				
				rhost = client.remote_address()
				lhost = client.local_address()
	
				puts "[*] connection from #{rhost} -> #{lhost}"
				message = client.gets
				puts message
			end
			return
		end
	end
end
