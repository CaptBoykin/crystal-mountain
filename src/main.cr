require "./serv.cr"
require "./auth.cr"
require "./agent-gen.cr"
require "./mt_rpc.cr"

require "option_parser"



def rpc_test_run(lhost : String, lport : Int32, rhost : String, rport : Int32) : Nil
	client = MtRpc::Client.new(lhost,lport)
	client.rpc_test(rhost,rport)
	return
end

def agent_generate_run : Nil
	p "[*] Generating new agent!"
	MtAgentGen.agent_create("myagent","0.0.0.0",9999,"myagent_cookie",["--static"])
	MtAgentGen.create_cookie_file("myagent_cookie","0.0.0.0")
	return
end

def agent_master_run : Nil
	procs = Process.fork do
	   p "[*] Starting agent check-in"
	   MtMaster.run_server(MtMaster.init_server("localhost",9999))
	end
	return
end

def rpc_master_run : Nil
	procs = Process.fork do
		p "[*] Starting RPC..."
		MtRpc::Server.new("127.0.0.1",9998).run
	end
	return
end

def cmd_run_run(cmd : String, lhost : String , lport : Int32 , rhost : String , rport : Int32) : Nil
    client = MtRpc::Client.new(lhost,lport)
    client.cmd_run(cmd,rhost,rport)
	return
end

def host_range_from_file(file : String) : (Array(String)|Bool)

	hosts = Array(String).new

	File.open(file,"r") do |fd|
		while host = fd.gets()
			hosts.push(host)
		end
	end

	if hosts.size == Nil
		return false
	else
		pp hosts
		return hosts
	end
end

OptionParser.parse do |parser|

	cmd = ""
	rhost = "127.0.0.1"
	rport = 12345
	lhost = "127.0.0.1"
	lport = 9998
	use_host_range = false
	rhosts = Array(String).new

	parser.on("-rh RHOST","--rhost=RHOST","Specify RHOST") do |rh|
		rhost = rh
	end
	
	parser.on("-rp RPORT","--rport=RPORT","Specify RPORT") do |rp|
		rport = rp.to_i
	end

	parser.on("-rhs RHOSTS","--rhosts=HOST_RANGE","Specify a range of RHOSTS.  Accepts: Comma delim single hosts OR a hosts file (one per line)") do |rhs|
		
		rhs.split(',').each do |x|
			rhosts.push(x)
		end

	use_host_range = true
	end
		

	parser.on("-t","--test","Test RPC 1") do 

		if ! use_host_range
			rpc_test_run(lhost,lport,rhost,rport)
		elsif rhosts != Nil
			rhosts.each do |host|
				rpc_test_run(lhost,lport,host,rport)
			end
		end
	end

	parser.on("-r","--rpc","Start RPC Master") do
		rpc_master_run()
	end
	
	parser.on("-m","--master","Start Agent Master") do 
		agent_master_run()
	end
	
	parser.on("-c CMD","--cmd-run=CMD","Send a shell cmd") do |str|
        if ! use_host_range
            cmd_run_run(str,lhost,lport,rhost,rport)
        elsif rhosts != Nil
            rhosts.each do |host|
                cmd_run_run(str,lhost,lport,host,rport)
            end
        end		
	

	end

	parser.on("-a","--agent","Generate a new agent") do
		agent_generate_run()
	end
	
	parser.on("-h","--help","This cruft") do
		puts parser
	end
end
