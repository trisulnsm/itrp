module ITRP

class Cmd_query_fts   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :fts
		@attach_cmd  = ''
		@trigger = 'query'
	end

	def completions(patt)
		%w( keywords ) 
	end

    def enter(patt)

	   terms = patt.scan( /keywords\s*=\s*(.+)/ )

		req =mk_request(TRP::Message::Command::QUERY_FTS_REQUEST,
						 { 	:fts_group  => appstate(:cgguid),
                         	:time_interval =>  appstate(:time_interval),
							:maxitems => 20,
							:keywords => terms.flatten.first 
						})


        rows = [] 

		get_response_zmq(@appenv.zmq_endpt,req) do |resp|

            resp.documents.each do | doc |
                rows << [ doc.dockey, 
                          doc.flows.inject("") do |acc,item|
                            item.key  + "( " + item.time.tv_sec.to_s  + ")"
                          end,
						  doc.fullcontent.size
                       ]
            end

        end

		table = Terminal::Table.new( 
				:headings => %w(DocID Flows Content),
				:rows => rows)
		puts(table) 
    end

end
end


