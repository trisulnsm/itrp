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

		[:maxitems].each do |a|
			qparams[a] = qparams[a].to_i if qparams.key? a
		end

		[:idlist].each do |a|
			qparams[a] = qparams[a].split(',')  if qparams.key? a
		end

	    p qparams 

		# convert following fields to KeyT
		#

		key_fields=[:source_ip,:source_port,:dest_ip,:dest_port,:any_ip,:any_port,
			 	    :protocol,:nf_routerid,:nf_ifindex_in,:nf_ifindex_out]

		# use set intersection 
		(key_fields & qparams.keys).each do |k|
			label = qparams[k] 
			qparams[k] = TRP::KeyT.new( :label => label)
		end

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

            rows << [ "#{sess.session_id}",
                      Time.at( sess.time_interval.from.tv_sec).to_s(),
					  sess.time_interval.to.tv_sec - sess.time_interval.from.tv_sec,
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
				:headings => %w(ID Time Dur Prot SourceIP DestIP SPort DPort Volume),
				:rows => rows)
		puts(table) 

    end


end
end


