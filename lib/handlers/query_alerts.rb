module ITRP

class Cmd_query_alerts   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :alerts
		@attach_cmd  = ''
		@trigger = 'query'
	end

	def completions(patt)
		TRP::QueryAlertsRequest
		        .fields
				.values
				.collect { |a| a.name }
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


		req =mk_request(TRP::Message::Command::QUERY_ALERTS_REQUEST,
						 { 	:alert_group  => appstate(:cgguid),
                         	:time_interval =>  appstate(:time_interval)
						 }.merge(qparams))


        rows = [] 

		labelfmt = lambda do |fld|
			fld.label.empty? ? fld.key : fld.label
		end

		get_response_zmq(@zmq_endpt,req) do |resp|

            resp.alerts.each do | res |


            rows << [ "#{res.alert_id}",
                      Time.at( res.time.tv_sec).to_s(),
					  res.occurrances, 
                      res.source_ip.label,
                      res.source_port.label,
                      res.destination_ip.label,
                      res.destination_port.label,
                      res.sigid.key,
                      res.priority.key,
                      res.classification.key
            ]
            end

        end

		table = Terminal::Table.new( 
				:headings => %w(ID Time Count SourceIP Port DestIP Port SigID Prio Class ),
				:rows => rows)
		puts(table) 

    end

end
end


