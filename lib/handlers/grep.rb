module ITRP

class Cmd_grep   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'grep'
	end

	def enter(cmdline)

		patt = cmdline.scan(/grep\s+(\w+)/).flatten.first 

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::GREP_REQUEST,
			 :time_interval => appstate(:time_interval),
			 :pattern_text => patt  )

		rows = []
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			sz = resp.sessions.size
			(0..sz-1).each  do |i|
				print "#{resp.sessions[i].session_key}    #{resp.hints[i]}\n"
			end
		end

	end

end
end

