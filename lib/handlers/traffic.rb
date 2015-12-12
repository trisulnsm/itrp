module ITRP

class Cmd_traffic < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'traffic'
	end



    def enter(cmdline)

        patt = cmdline.scan(/traffic\s+(.*)/).flatten.first 
		patt ||= "0"
		showmeters = patt.split(',').map(&:to_i)

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
			 :key => TRP::KeyDetails.new({ :label => @appenv.context_data[:cgkey]}) ,
			 :time_interval =>  mk_time_interval(@appenv.context_data[:time_window]) )

		rows  = [] 

	
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  print "Counter Group = #{resp.stats.counter_group}\n"
			  print "Key           = #{resp.stats.key}\n"

			  tseries  = {}
			  resp.stats.meters.each do |meter|
				meter.values.each do |val|
					tseries[ val.ts.tv_sec ] ||= []
					tseries[ val.ts.tv_sec ]  << val.val 
				end
			  end


			  rows = []
			  tseries.each do |ts,valarr|
			  	rows << [ ts, valarr ].flatten 
			  end

			  table = Terminal::Table.new(:headings => colnames,  :rows => rows )
			  puts(table) 
		end

	end

end
end

