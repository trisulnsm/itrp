module ITRP

class Cmd_fts < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = 'set'
		@trigger = 'fts'
	end


    def completions(patt)
        [ "HTTP Headers  {28217924-E7A5-4523-993C-44B52758D5A8}",
          "SSL Certs     {9FEB8ADE-ADBB-49AD-BC68-C6A02F389C71}",
        ].grep( /#{Regexp.escape(patt)}/i)  
    end


	def enter(s)
        patt = s.scan(/set\s+fts\s+(.*)\s+({.*}$)/).flatten 
		patt[0].strip!
		print("\nContext set to FTS (Full Text Search) [#{patt[0]}] [#{patt[1]}]\n\n")
		@appenv.prompt = "iTRP D:(#{patt[0]})> "
		@appenv.context_data[:cgguid] = patt[1]
		@appenv.context_data[:cgname] = patt[0]
		@appenv.context = :fts
	end
end



end 
