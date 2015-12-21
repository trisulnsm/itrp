module ITRP

class Cmd_probe   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'probe'
	end

	def enter(cmdline)

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::PROBE_STATS_REQUEST,
			 :param => "nothing" )

		rows = []
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
		
			p resp
		end

	end

end
end

