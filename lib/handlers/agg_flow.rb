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
						 :group_by_fields => ['any_ip','flowtag','protocol'] 
						}.merge(qparams))


		get_response_zmq(@appenv.zmq_endpt,req) do |resp|

			%w(dest_ip dest_port  protocol).each do |fieldname| 

				rows = [] 
				rows << resp.send(fieldname).collect  do |item|
					 [item.key.key, item.key.readable, item.key.label, item.count, item.metric]
				end

				table = Terminal::Table.new( 
						:headings => [fieldname, 'Readable', 'Label', 'Flows', 'Metric'  ],
						:rows => rows.first )
				puts(table) 

			end 

			# tags
			resp.tag_group.each do |tg|

				puts(tg.group_name)

				rows = [] 
				rows << tg.tag_metrics.collect  do |item|
					 [item.key.key, item.count, item.metric]
				end

				table = Terminal::Table.new( 
						:headings => ['Tag', 'Flows', 'Metric'  ],
						:rows => rows.first )
				puts(table) 


			end 

		end


    end


end
end


