module ITRP

class Cmd_help < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'help'
	end
end

end

