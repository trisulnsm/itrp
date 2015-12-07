module ITRP

class Cmd_counter < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = 'set'
		@trigger = 'counter'
	end

	def completions(patt) 
		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST)
		cgdtls = []

		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
				 cgdtls <<   group_detail.name
				 cgdtls <<   group_detail.guid
			  end
		end

		cgdtls.grep( /^#{Regexp.escape(patt)}/i)

	end

	
	def enter(cmdline)
		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST)
		patt = cmdline.scan(/set\s+counter\s+(.*)/).flatten.first 
		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
				 if group_detail.name == patt 
				 	print("\nContext set to counter group [#{group_detail.name}] [#{group_detail.guid}]\n\n")
					@appenv.prompt = "iTRP C:(#{patt})> "
					@appenv.context_data[:cgguid] = group_detail.guid 
					@appenv.context_data[:cgname] = group_detail.name 
					@appenv.context  = :counter 
					return
				 end
			  end
		end

	end


end

end 

