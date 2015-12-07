module ITRP

class Cmd_flow < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = 'set'
		@trigger = 'flow'
	end


    def completions(patt)
        [ 
			"IP Flows {99A78737-4B41-4387-8F31-8077DB917336}"
        ].grep( /#{Regexp.escape(patt)}/i)  
    end

	def enter(s)
        patt = s.scan(/set\s+flow\s+(.*)\s+({.*}$)/).flatten 
		patt = ["IP Flows",   "{99A78737-4B41-4387-8F31-8077DB917336}"]  if  patt.empty?
		print("\nContext set to flow group [#{patt[0]}] [#{patt[1]}]\n\n")
		@appenv.prompt = "iTRP F:(#{patt[0]})> "
		@appenv.context_data[:cgguid] = patt[1]
		@appenv.context_data[:cgname] = patt[0]
		@appenv.context = :flow
	end
end

end 
