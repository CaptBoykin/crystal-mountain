require "uuid"
require "random/secure"
require "openssl"


module MtAuth
	extend self

	def generate_token(hostname : String) : (String|Nil)
		uuid = UUID.random()
		return "#{hostname}|#{uuid}"
	end

	def init_ssl_pkay_rsa() : (Nil)
		return
	end

	def generate_cookie(token : String) : (String|Nil)
		#key = OpenSSL::PKey::RSA.generate(1024)
		
		#p "[*] #{typeof(key)}"

		#data = token
		#encrypted = key.private_encrypt data
		#return String.new(decrypted)
		return token
	end


	def decrypt_cookie(data : String, keyfile : String) : (String|Nil)
		return
	end


end
