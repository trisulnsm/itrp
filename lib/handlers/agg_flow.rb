module ITRP

# usage agg proto=11 group_by:nf_routerid,nf_ifindex_out,nf_ifindex_in 

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

	    print("Query Params=#{qparams}\n")

		group_by = patt.scan( /group_by:(\S+)/ )
		group_by.flatten! 
		if not group_by.empty? then 
		  group_by  = group_by[0]
	    else
		  group_by = "" 
        end 

	    print("Group By =#{group_by}\n")


		# meter names 
		req =mk_request(TRP::Message::Command::AGGREGATE_SESSIONS_REQUEST ,
						{
						 :session_group  => appstate(:cgguid),
                         :time_interval => appstate(:time_interval),
						 :resolve_keys => true,
						 :group_by_fields => group_by.split(',') 
						}.merge(qparams))


		get_response_zmq(@appenv.zmq_endpt,req) do |resp|

			%w(dest_port  nf_routerid nf_ifindex_in nf_ifindex_out ).each do |fieldname| 

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


