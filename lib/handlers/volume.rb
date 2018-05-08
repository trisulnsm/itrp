module ITRP

class Cmd_volume < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'volume'
	end



    def enter(cmdline)

		#volume TOTALBW, 0
        patt = cmdline.scan(/volume\s+(\S+)\s*,\s*(\d*)/).flatten

		p patt 

		use_key = patt.empty? ? appstate(:cgkey)  : patt[0]
		use_meter = patt[1].to_i  || 0 

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
			 :counter_group => @appenv.context_data[:cgguid],
			 :key => use_key, 
			 :volumes_only => 1,
			 :time_interval =>  appstate( :time_interval) ) 

		rows  = [] 

		print "Request sent at  #{Time.now}\n"
	
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|

			total = 0 
			resp.stats.each do |tsval|
			  	total += tsval.values[use_meter]
			end

			print( "Total = #{total * 60 }\n")

		end

	end

end
end

