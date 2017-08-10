module ITRP

class Cmd_alert < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = 'set'
		@trigger = 'alert'
	end


    def completions(patt)
        [  "IDS           {9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}",
           "Blacklist {5E97C3A3-41DB-4E34-92C3-87C904FAB83E}",
           "TCA {03AC6B72-FDB7-44C0-9B8C-7A1975C1C5BA}",
           "SYS      {18CE5961-38FF-4AEA-BAF8-2019F3A09063}",
           "TB      {0E7E367D-4455-4680-BC73-699D81B7CBE0}"
        ].grep( /#{Regexp.escape(patt)}/i)  
    end

	def enter(s)
        patt = s.scan(/set\s+alert\s+(\S+)\s+({.*}$)/).flatten 
		print("\nContext set to alert group [#{patt[0]}] [#{patt[1]}]\n\n")
		@appenv.prompt = "iTRP A:(#{patt[0]})> "
		@appenv.context_data[:cgguid] = patt[1]
		@appenv.context_data[:cgname] = patt[0]
		@appenv.context = :alerts

	end
end

end 
