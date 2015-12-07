module ITRP

class Cmd_alert < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = 'set'
		@trigger = 'alert'
	end


    def completions(patt)
        [  "External IDS           {9AFD8C08-07EB-47E0-BF05-28B4A7AE8DC9}",
           "Blacklist activity BL  {5E97C3A3-41DB-4E34-92C3-87C904FAB83E}",
           "Threshold crossing TCA {03AC6B72-FDB7-44C0-9B8C-7A1975C1C5BA}",
           "System Alerts SYS      {18CE5961-38FF-4AEA-BAF8-2019F3A09063}",
           "Threshold Band TB      {0E7E367D-4455-4680-BC73-699D81B7CBE0}"
        ].grep( /#{Regexp.escape(patt)}/i)  
    end

	def enter(s)
		puts("Process set alert ");

	end
end

end 
