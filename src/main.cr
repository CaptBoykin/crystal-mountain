require "./serv.cr"
require "./auth.cr"
require "./agent-gen.cr"
require "./mt_rpc.cr"

#MtAgentGen.agent_create("myagent","127.0.0.1",9999,"myagent_cookie")
#MtAgentGen.create_cookie_file("myagent_cookie","127.0.0.1")

rpcserver = MtRpcServ.new

procs = Process.fork do		
	p "[*] Starting agent check-in"
	MtMaster.run_server(MtMaster.init_server("localhost",9999))
	
	p "[*] Starting RPC..."
	rpcserver.rpc_init("localhost",9998)
end
