module ITRP

class Cmd_root < Cmd 

	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = ''
	end
	

	def enter(cmdline)
	print("Cmdrootenter")
		unless ["","reload", "clear" ].member? cmdline.strip
			print("#{cmdline}  #{@enabled_in_state} : not found\n");
		end
	end
end

end
