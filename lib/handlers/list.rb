module ITRP

class Cmd_list < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'list'
	end
end

end

