require "./serv.cr"
require "./auth.cr"
require "./agent-gen.cr"
require "./mt_rpc.cr"

require "option_parser"


def rpc_test_run(lhost : String, lport : Int32, rhost : String, rport : Int32) : Nil
	client = MtRpc::Client.new(lhost,lport)
	client.rpc_test(rhost,rport)
end

def agent_generate_run : Nil
	p "[*] Generating new agent!"
	MtAgentGen.agent_create("myagent","127.0.0.1",9999,"myagent_cookie")
	MtAgentGen.create_cookie_file("myagent_cookie","127.0.0.1")
end

def agent_master_run : Nil
	procs = Process.fork do
	   p "[*] Starting agent check-in"
	   MtMaster.run_server(MtMaster.init_server("localhost",9999))
	end
end

def rpc_master_run : Nil
	procs = Process.fork do
		p "[*] Starting RPC..."
		MtRpc::Server.new("127.0.0.1",9998).run
	end
end

def cmd_run_run(cmd : String, lhost : String , lport : Int32 , rhost : String , rport : Int32) : Nil
    client = MtRpc::Client.new(lhost,lport)
    client.cmd_run(cmd,rhost,rport)
	return
end

OptionParser.parse do |parser|

	cmd = ""
	rhost = "127.0.0.1"
	rport = 12345
	lhost = "127.0.0.1"
	lport = 9998

	parser.on("-rh RHOST","--rhost=RHOST","Specify RHOST") do |rh|
		rhost = rh
	end
	
	parser.on("-rp RPORT","--rport=RPORT","Specify RPORT") do |rp|
		rport = rp.to_i
	end

	parser.on("-t","--test","Test RPC 1") do 
		rpc_test_run(lhost,lport,rhost,rport)
	end

	parser.on("-r","--rpc","Start RPC Master") do
		rpc_master_run()
	end
	
	parser.on("-m","--master","Start Agent Master") do 
		agent_master_run()
	end
	
	parser.on("-c CMD","--cmd-run=CMD","Send a shell cmd") do |str|
		cmd_run_run(str,lhost,lport,rhost,rport)		
	end

	parser.on("-a","--agent","Generate a new agent") do
		agent_generate_run()
	end
	
	parser.on("-h","--help","This cruft") do
		puts parser
	end
end
