module ITRP

class Cmd_keyspace < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'keyspace'
	end



    def enter(cmdline)

        patt = cmdline.scan(/keyspace\s+(\S+)\s*(\S+)/).flatten

		p "#{patt[0]} to #{patt[1]}" 

         use_spaces =  [ TRP::KeySpaceRequest::KeySpace.new(
                      :from_key => TRP::KeyT.new( :label => patt[0]), 
                      :to_key   => TRP::KeyT.new( :label => patt[1]) ) ]

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::KEYSPACE_REQUEST,
			 :counter_group => @appenv.context_data[:cgguid],
			 :time_interval =>  appstate( :time_interval),
			 :totals_only => false,
			 :get_key_attributes => true,
			 :maxitems => 10)

		rows  = [] 

	
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|

                resp.hits.each_with_index  do |kt,i | 

					p kt

			  		attr_str = kt.attributes.inject( "") do  |acc,h| 
						acc << "#{h.attr_name}=#{h.attr_value} " 
					end 

                    rows << [ i, kt.key, kt.label, kt.readable, attr_str ]
                end 

				p "TOTAL HITS = #{resp.total_hits}" 
		end



		table = Terminal::Table.new( 
				:headings => %w(# Key Label Readable Attributes ),
				:rows => rows)
		puts(table) 

	end

end
end

