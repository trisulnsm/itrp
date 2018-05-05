module ITRP

class Cmd_flow_trackers   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :flow
		@attach_cmd  = ''
		@trigger = 'tracker'
	end

	def enter(cmdline)


		terms = cmdline.scan( /(\w+)\s*=\s*([\w\-_\.\:,]+)+/ )
		qparams = terms.inject({}) { |acc,t| acc.store( t[0].to_sym, t[1]);acc}

		p qparams 

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::SESSION_TRACKER_REQUEST,
			 qparams.merge(
			 :session_group  => appstate(:cgguid),
			 :time_interval => appstate(:time_interval),
			 :resolve_keys => true))

		rows = []
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
		
			resp.sessions.each do | sess |

			rows << [ "#{sess.session_key}",
					  Time.at( sess.time_interval.from.tv_sec).to_s(),
					  sess.probe_id,
					  sess.protocol.label,
					  sess.key1A.label,
					  sess.key1Z.label,
					  sess.key2A.label,
					  sess.key2Z.label,
					  sess.nf_routerid.nil? ? "": sess.nf_router_id.label,
					  sess.nf_ifindex_in.nil? ? "": sess.nf_ifindex_in.label,
					  sess.nf_ifindex_out.nil? ? "": sess.nf_ifindex_out.label,
					  sess.tracker_statval 
					]
			end

		end

		table = Terminal::Table.new( 
				:headings => %w(Key Last-Seen ProbeID Prot SourceIP DestIP SPort DPort Rtr IfIn IfOut TrackerVal),
				:rows => rows)
		puts(table) 


	end

end
end

