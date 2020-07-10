require "simple_rpc"
require "socket"

class MtRpc

	include SimpleRpc::Proto

	def rpc_test_hook(rhost : String, rport : Int32) : (Bool)
		#connfd = TCPSocket.new("192.168.1.68", 12345)
		connfd = TCPSocket.new(rhost,rport)
		connfd << "TEST from RPC\n"
		connfd.close
		return true
	end

	def cmd_run_hook(cmd : String, rhost : String, rport : Int32) : (Bool)
		connfd = TCPSocket.new(rhost,rport)
		connfd << cmd
		connfd << "\r\n"

		pp connfd.gets
		connfd.close
		return true
	end

	class Client
		def rpc_test(rhost : String, rport : Int32) : (Bool)
			result = rpc_test_hook(rhost,rport)
			if result.ok?
				return true
			else
				return false
			end
		end

		def cmd_run(cmd : String, rhost : String, rport : Int32) : (Bool)
			result = cmd_run_hook(cmd,rhost,rport)
			if result.ok?
				return true
			else
				return false
			end
		end
	end
end
