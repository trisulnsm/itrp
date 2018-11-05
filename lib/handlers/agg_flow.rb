module ITRP

class Cmd_agg_flow   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :flow
		@attach_cmd  = ''
		@trigger = 'agg'
	end

	def completions(patt)
		TRP::AggregateSessionsRequest
		        .fields
				.values
				.collect { |a| a.name.to_s  }
				.grep( /^#{Regexp.escape(patt)}/i)
	end

    def enter(patt)

		terms = patt.scan( /(\w+)\s*=\s*([\w\-_\.\:,]+)+/ )
		qparams = terms.inject({}) { |acc,t| acc.store( t[0].to_sym, t[1]);acc}

	    p qparams 

		# meter names 
		req =mk_request(TRP::Message::Command::AGGREGATE_SESSIONS_REQUEST ,
						{
						 :session_group  => appstate(:cgguid),
                         :time_interval => appstate(:time_interval),
						 :resolve_keys => true,
						}.merge(qparams))

        rows = [] 

		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			rows << resp.protocol.collect  do |item|
				if item.key then
			 	 [item.key.key, item.key.readable, item.key.label, item.count]
				else
				 ["nil",0]
				end 
			end
			
        end

		p rows 

		table = Terminal::Table.new( 
				:headings => %w(SourceIP Readable Label Volume ),
				:rows => rows.first )
		puts(table) 


    end


end
end


