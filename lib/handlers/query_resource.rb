module ITRP

class Cmd_query_resource  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :resource
		@attach_cmd  = ''
		@trigger = 'query'
	end

	def completions(patt)
		TRP::QueryResourcesRequest
		        .fields
				.values
				.collect { |a| a.name.to_s }
				.grep( /^#{Regexp.escape(patt)}/i)
	end

    def enter(patt)

		terms = patt.scan( /(\w+)\s*=\s*([\w\-_\.\:,]+)+/ )

		qparams = terms.inject({}) { |acc,t| acc.store( t[0].to_sym, TRP::KeyT.new(:label=>t[1]));acc}

		[:maxitems].each do |a|
			qparams[a] = qparams[a].to_i if qparams.key? a
		end

		[:ip_pair].each do |a|
            if qparams[a]
                qparams[a] = qparams[a].split(',')
                            .collect do |e|
                             TRP::KeyT.new( :label => e )
                            end
            end
		end

	    p qparams 

		# meter names 
		req =mk_request(TRP::Message::Command::QUERY_RESOURCES_REQUEST,
						{
						 :resource_group => appstate(:cgguid),
                         :time_interval => appstate(:time_interval)
						}.merge(qparams))

        rows = [] 

		get_response_zmq(@appenv.zmq_endpt,req) do |resp|

            resp.resources.each do | res |

            rows << [ "#{res.resource_id}",
                      Time.at( res.time.tv_sec).to_s(),
                      res.source_ip.label,
                      res.source_port.label,
                      res.destination_ip.label,
                      res.destination_port.label,
                      wrap(res.uri,50),
                      wrap(res.userlabel,40)
            ]
            end

        end

		table = Terminal::Table.new( 
				:headings => %w(ID Time SourceIP Port DestIP Port URI Label ),
				:rows => rows)
		puts(table) 

    end


end
end


