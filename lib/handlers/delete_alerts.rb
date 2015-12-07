module ITRP

class Cmd_delete_alerts  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :alerts
		@attach_cmd  = ''
		@trigger = 'delete'
	end

	def completions(patt)
		TRP::DeleteAlertsRequest
		        .fields
				.values
				.collect { |a| a.name }
				.grep( /^#{Regexp.escape(patt)}/i)
	end


    def enter(cmdline)

		terms = patt.scan( /(\w+)\s*=\s*([\w\-_\.\:,]+)+/ )
		qparams = terms.inject({}) { |acc,t| acc.store( t[0].to_sym, t[1]);acc}

	    p qparams 

		# meter names 
		req =mk_request(TRP::Message::Command::DELETE_ALERTS_REQUEST,
						 { 	:alert_group  => appstate(:cgguid),
                         	:time_interval =>  apstate(:time_interval) 
						 }.merge(qparams))


		resp = get_response_zmq(@appenv.zmq_endpt,req)

        puts(resp.message)

    end


end
end

