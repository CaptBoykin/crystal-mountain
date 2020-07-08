require "simple_rpc"
require "socket"

class MtRpc

	include SimpleRpc::Proto

	def ok_test : String
		connfd = TCPSocket.new("127.0.0.1", 12345)
		connfd << "TEST from RPC\n"
		connfd.close
		return "OK\r\n"	
	end

	class Client
		def rpc_test : (Nil|Bool)
			result = ok_test()
			p result
			return
		end
	end
end
