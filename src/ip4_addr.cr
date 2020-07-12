module Ip4

	# Start at the network boundary range
	# Include all hosts
	# Increment the network segments when hosts reach over 255


	extend self

	CIDR_LEN = {
	32 => 1 , 31 => 2 , 30 => 4,
	29 => 8 , 28 => 16, 27 => 32,
	26 => 64, 25 => 128, 24 => 255
	}

	
	C_LENS = {
	24 => 1, 23 => 2, 22 => 4, 21 => 8,
	20 => 16, 19 => 32, 18 => 64, 17 => 128,
	16 => 256, 15 => 512, 16 => 1024, 15 => 2048,
	14 => 4096, 13 => 8192, 12 => 16384, 11 => 32768,
	10 => 65536, 9 => 131072, 8 => 262144 
	}
	

	def is_valid(addr : String) : Bool
	
		addr.each_char do |c|
			if c != '.'
				begin
					if ! c.to_i.is_a?(Int32)
						return false
					end
				rescue
					return false
				end
			end
		end
		


		dots = 0
		addr.each_char do |c|
			if c == '.'
				dots += 1
			end
		end		

		if dots != 3
			return false
		end


		addr_arr = addr.split('.')
		begin
			if addr.split('.').size != 4
				return false
			end
		rescue
			return false
		end			

		addr_arr.each do |addr|
			begin
				if addr.size > 3
					return false
				end

				if addr.to_i > 255
					return false
				elsif addr.to_i < 0
					return false
				end
			rescue
				return false
			end
		end

		begin
			if addr_arr[0].to_i == 0
				return false
			end
		
			if addr_arr[3].to_i == 0
				return false
			end
		rescue
			return false
		end
		return true		
	end

	def subnet_to_hosts(range : String) : Array(String)
		
		hosts = Array(String).new

		network = range.split('/')[0].split('.').map do |num|
			num.to_i
		end

		mask = range.split('/')[1].to_i
	
		return hosts
	end


end

