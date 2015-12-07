module ITRP

class Cmd_set < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'set'
	end

	def enter(cmdline)
		print("\nCurrent state\n")
		print_state
	end
end

class Cmd_reset < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'reset'
	end

	def enter(cmdline)
		@appenv.prompt = "iTRP> "
		@appenv.context  = :any  
		print_state
		print("\nReset state OK\n")
	end

end

end

