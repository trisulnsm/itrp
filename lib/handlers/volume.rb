module ITRP

class Cmd_volume < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'volume'
	end



    def enter(cmdline)

		#volume TOTALBW [0]
        patt = cmdline.scan(/volume\s+(\S+)\s*(\d*)/).flatten


		use_key = patt.empty? ? appstate(:cgkey)  : patt[0]
		use_meter = patt[1].to_i  || 0 
        if use_key=="SYS:GROUP_TOTALS"
          use_key=TRP::KeyT.new({key:"SYS:GROUP_TOTALS"})
        end

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_ITEM_REQUEST,
			 :counter_group => @appenv.context_data[:cgguid],
			 :key => use_key, 
			 :volumes_only => 1,
			 :get_percentile => 95,
			 :time_interval =>  appstate( :time_interval) ) 

		rows  = [] 


		print "Request sent at  #{Time.now}\n"
	
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|

			tot= resp.totals.values[use_meter]
			max = resp.maximums.values[use_meter]
			min = resp.minimums.values[use_meter]
			smp = resp.samples.values[use_meter]
			lat = resp.latests.values[use_meter]

			pct = 0
			if resp.percentiles
				pct   = resp.percentiles.values[use_meter]
			end 

			p resp 

			print( "Total      : #{as_size_volume(tot * 60) }\n")
			print( "Percentile : #{as_size_bw(pct*8) }\n")
			print( "Max        : #{as_size_bw(max * 8) }\n")
			print( "Min        : #{as_size_bw(min * 8) }\n")
			print( "Samples    : #{smp} \n")
			print( "Latest     : #{as_size_bw(lat * 8) }\n")

		end

	end

end
end

