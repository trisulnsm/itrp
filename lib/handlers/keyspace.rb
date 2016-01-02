module ITRP

class Cmd_keyspace < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'keyspace'
	end



    def enter(cmdline)

        patt = cmdline.scan(/keyspace\s+(.*)\s(.*)/).flatten

		p "#{patt[0]} to #{patt[1]}" 

         use_spaces =  [ TRP::KeySpaceRequest::KeySpace.new(
                      :from_key => TRP::KeyT.new( :label => patt[0]), 
                      :to_key   => TRP::KeyT.new( :label => patt[1]) ) ]

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::KEYSPACE_REQUEST,
			 :counter_group => @appenv.context_data[:cgguid],
			 :time_interval =>  appstate( :time_interval),
             :spaces => use_spaces ) 

		rows  = [] 

	
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|

                resp.hits.each_with_index  do |kt,i | 
                    rows << [ i, kt.key, kt.label, kt.readable ]
                end 

		end

		table = Terminal::Table.new( 
				:headings => %w(# Key Label Readable ),
				:rows => rows)
		puts(table) 

	end

end
end

