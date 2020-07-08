require "simple_rpc"
require "socket"

class MtRpc

	include SimpleRpc::Proto

	def rpc_test_hook(rhost : String, rport : Int32) : String
		#connfd = TCPSocket.new("192.168.1.68", 12345)
		connfd = TCPSocket.new(rhost,rport)
		connfd << "TEST from RPC\n"
		connfd.close
		return "OK\r\n"	
	end

	def cmd_run_hook(cmd : String, rhost : String, rport : Int32) : String
		connfd = TCPSocket.new(rhost,rport)
		connfd << cmd
		connfd.close
		return "OK\r\n"
	end

	class Client
		def rpc_test(rhost : String, rport : Int32) : Nil
			result = rpc_test_hook(rhost,rport)
			p result
			return
		end

		def cmd_run(cmd : String, rhost : String, rport : Int32) : Nil
			result = cmd_run_hook(cmd,rhost,rport)
			p result
			return
		end
	end
end
