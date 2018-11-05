module ITRP

class Cmd_query_flow   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :flow
		@attach_cmd  = ''
		@trigger = 'query'
	end

	def completions(patt)
		TRP::QuerySessionsRequest
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
		req =mk_request(TRP::Message::Command::QUERY_SESSIONS_REQUEST ,
						{
						 :session_group  => appstate(:cgguid),
                         :time_interval => appstate(:time_interval),
						 :resolve_keys => true,
						}.merge(qparams))

        rows = [] 

		get_response_zmq(@appenv.zmq_endpt,req) do |resp|

            resp.sessions.each do | sess |

			p sess 

            rows << [ "#{sess.session_id}",
                      Time.at( sess.time_interval.from.tv_sec).to_s(),
					  sess.time_interval.to.tv_sec - sess.time_interval.from.tv_sec,
                      sess.probe_id,
                      sess.protocol.label,
                      sess.key1A.label,
                      sess.key1Z.label,
                      sess.key2A.label,
                      sess.key2Z.label,
                      sess.az_bytes + sess.za_bytes
					]
            end

        end

		table = Terminal::Table.new( 
				:headings => %w(ID Time Dur Prb  Prot SourceIP DestIP SPort DPort rtr IFin out Volume),
				:rows => rows)
		puts(table) 

    end


end
end


