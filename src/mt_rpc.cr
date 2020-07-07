require "simple_rpc"


class MtRpcServ

	include SimpleRpc::Proto

	def rpc_init(addr : String, port : Int32) : (Nil)
		while true
			procs = Process.fork do
				MtRpcServ::Server.new(addr,port).run
			end
	
		procs.wait
		end

		return
	end
end


class MtRpcMethods

	include SimpleRpc::Proto

	def test() : String
		return "OK"
	end

end


class MtRpcHooks < MtRpcMethods

	include SimpleRpc::Proto

	def rpc_test() : (Nil|Bool)

		procs = Process.fork do
			client = MtRpcHooks::Client.new("127.0.0.1",9998)
			result = MtRpcHooks.test()
			p result
		end

		procs.wait
		return
	end
end
