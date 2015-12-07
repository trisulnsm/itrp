module ITRP

class Cmd_resource  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = 'set'
		@trigger = 'resource'
	end


	def completions(patt)
        [ "HTTP URIs     {4EF9DEB9-4332-4867-A667-6A30C5900E9E} ",
          "DNS Resources {D1E27FF0-6D66-4E57-BB91-99F76BB2143E} ",
          "SSL Certs     {5AEE3F0B-9304-44BE-BBD0-0467052CF468} ",
        ].grep( /#{Regexp.escape(patt)}/i)  
    end

	def enter(s)
        patt = s.scan(/set\s+resource\s+(.*)\s+({.*}$)/).flatten 
		patt[0].strip!
		print("\nContext set to resource group [#{patt[0]}] [#{patt[1]}]\n\n")
		@appenv.prompt = "iTRP R:(#{patt[0]})> "
		@appenv.context_data[:cgguid] = patt[1]
		@appenv.context_data[:cgname] = patt[0]
		@appenv.context = :resource
	end
end

end 
