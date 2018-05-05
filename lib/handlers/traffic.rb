module ITRP

class Cmd_traffic < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'traffic'
	end



    def enter(cmdline)

        patt = cmdline.scan(/traffic\s+(.*)/).flatten

		p patt 

		use_key = patt.empty? ? appstate(:cgkey)  : patt[0]

		# meter names 
		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
						 :counter_group => @appenv.context_data[:cgguid],
						 :get_meter_info => true )

		colnames   = ["Timestamp"]
		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
			  	group_detail.meters.each do |meter|
					colnames  <<  meter.name  
				end
			  end
		end


		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
			 :counter_group => @appenv.context_data[:cgguid],
			 :key => use_key, 
			 :time_interval =>  appstate( :time_interval) ) 

		rows  = [] 

		print "Request sent at  #{Time.now}\n"
	
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  print "Counter Group = #{resp.counter_group}\n"
			  print "Key           = #{resp.key.key}\n"
			  print "Readable      = #{resp.key.readable}\n"
			  print "Label         = #{resp.key.label}\n"
			  print "Description   = #{resp.key.description}\n"
			  print "Num intervals = #{resp.stats.size}\n"

			  print "Response at  #{Time.now}\n"

			  resp.stats.each do |tsval|
			  	rows << [ Time.at(tsval.ts_tv_sec), tsval.values  ].flatten 
			  end

			  table = Terminal::Table.new(:headings => colnames,  :rows => rows )
			  puts(table) 
		end

	end

end
end

