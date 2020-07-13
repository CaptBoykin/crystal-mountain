require "./bin_paths.cr"
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

	def drop_to_shell(rhost : String, rport : Int32) : Nil
		connfd = TCPSocket.new(rhost,rport)

		connfd << "hostname\r\n"
		hostname = connfd.gets
		connfd.gets

		connfd << "whoami\r\n"
		username = connfd.gets
		connfd.gets

		while true
			printf("%s","#{username}@#{hostname}: ")
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

	def file_upload : Nil
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

	def term_menu : Nil
	end

	

end
