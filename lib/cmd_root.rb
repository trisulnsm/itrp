module ITRP

class Cmd_root < Cmd 

	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = ''
	end
	

	def enter(cmdline)
	end

	def notfound(cmdline)
		print("#{cmdline}  : not found\n");
	end
end

end
