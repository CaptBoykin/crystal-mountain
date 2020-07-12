require "./serv.cr"
require "./auth.cr"
require "./agent-gen.cr"
require "./mt_rpc.cr"
require "./ip4_addr.cr"

require "option_parser"



def rpc_test_run(lhost : String, lport : Int32, rhost : String, rport : Int32) : Nil
	client = MtRpc::Client.new(lhost,lport)
	client.rpc_test(rhost,rport)
	return
end

def agent_generate_run(agent_opts : Array(String), agent_name : String, agent_lhost : String, agent_lport : Int32, cookie_file : String) : Nil
	p "[*] Generating new agent!"
	MtAgentGen.agent_create(agent_name,agent_lhost,agent_lport,cookie_file,agent_opts)
	MtAgentGen.create_cookie_file(agent_name,agent_lhost)
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

	return hosts
end

OptionParser.parse do |parser|

	cmd = ""
	rhost = "127.0.0.1"
	rport = 9999
	lhost = "127.0.0.1"
	lport = 9998
	use_host_range = false
	rhosts = Array(String).new
	agent_opts = Array(String).new
	agent_name = "myagent"
	agent_lhost = "0.0.0.0"
	agent_lport = 9999
	cookie_file = "myagent_cookie"	

	parser.on("--agent-rhost=RHOST","Specify address of a single agennt") do |rh|
		rhost = rh
	end
	
	parser.on("--agent-rport=RPORT","Specify port of a single agent") do |rp|
		rport = rp.to_i
	end

	parser.on("--gen-agent-name=NAME","Specify Agent Name during generation") do |name|
		agent_name = name
	end

	parser.on("--gen-agent-lhost","Specify listening addred during generation") do |glhost|
		agent_lhost = glhost
	end

	parser.on("--gen-agent-lport","Specify listening port during generation") do |glport|
		agent_lport = glport.to_i
	end

	parser.on("--agent-rhosts=HOST_RANGE","Specify a range of RHOSTS. Comma delmin, (fmt. x.x.x.x:pp) OR a hosts file of the same fmt. (one per line). pp defaults to 9999") do |rhs|
	
		begin
			if File.file?(rhs)
				rhosts = host_range_from_file(rhs)
			else
				rhs.split(',').each do |x|
					rhosts.push(x)
				end
			end
		rescue
			p "[-] --rhosts accepts either comma delim hosts or a one-per-line rhosts file"
		end

		use_host_range = true
	end
		
	parser.on("--gen-agent-compile-opts=OPTS","Agent linking options, comma delim") do |opts|
		opts.split(',').each do |opt|
			if opt == "static"
				agent_opts.push("--static")
			end
			if opt == "release"
				agent_opts.push("--release")
			end
			if opt == "cross-compile"
				agent_opts.push("--cross-compile")
			end
			if opt == "progress"
				agent_opts.push("--progress")
			end
			if opt == "verbose"
				agent_opts.push("--verbose")
			end
			if opt == "thin"
				agent_opts.push("--lto=thin")
			end
		end
	end

	parser.on("--test-run","Test RPC 1") do 
		if ! use_host_range
			rpc_test_run(lhost,lport,rhost,rport)
		elsif use_host_range
			rhosts.each do |host|
				o_rhost = host
				o_rport = rport
				begin
					port = host.split(':')[1].to_i
				rescue
					port = o_rport
				end
			
				begin
					host = host.split(':')[0]
				rescue
					host = o_rhost
				end	
				
				if Ip4.is_valid(host)
					rpc_test_run(lhost,lport,host,port)
				else
					p "[-] #{host} is not a valid address. Skipping..."
				end
			end
		end
	end


	parser.on("--rpc-run","Start RPC Master") do
		rpc_master_run()
	end
	
	parser.on("--agent-master-run","Start Agent Master") do 
		agent_master_run()
	end
	
	parser.on("--cmd-run=CMD","Send a shell cmd") do |str|
        if ! use_host_range
            cmd_run_run(str,lhost,lport,rhost,rport)
		elsif use_host_range
			rhosts.each do |host|
				
				o_rhost = host
				o_rport = rport
				begin
					port = host.split(':')[1].to_i				
				rescue
					port = o_rport
				end

				begin
					host = host.split(':')[0]
				rescue
					host = o_rhost
				end

				if Ip4.is_valid(host)
					cmd_run_run(str,lhost,lport,host,port)
				else
					p "[-] #{host} is not a valid address. Skipping..."
				end
            end
        end		
	end

	parser.on("--gen-agent","Generate a new agent") do
		agent_generate_run(agent_opts,agent_name,agent_lhost,agent_lport,cookie_file)
	end
	
	parser.on("-h","--help","This cruft") do
		puts parser
	end
end
