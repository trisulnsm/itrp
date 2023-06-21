module ITRP

class Cmd_toptrend  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'toptrend'
	end

	def enter(cmdline)

		patt = cmdline.scan(/toptrend ([0-9]+)/).flatten.first 

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::TOPPER_TREND_REQUEST,
			 :counter_group => @appenv.context_data[:cgguid],
			 :meter => patt.to_i,
			 :maxitems  => 10,
			 :key_filter => "0A.75.E0.14_00000021",
			 :time_interval =>  mk_time_interval(@appenv.context_data[:time_window]))

		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  print "Counter Group = #{resp.counter_group}\n"
			  print "Meter = #{resp.meter}\n"

			  rows = [] 
			  resp.keytrends.each do |ks|
					  print("Trends for key #{ks.key.label}\n")

					  ks.key.attributes.each  do |a|
						puts "#{a.attr_name}=#{a.attr_value}"
					  end

					  rows = []
					  ks.meters.each do |meter|
						meter.values.each do |val|
							rows << [Time.at(val.ts.tv_sec).to_s,val.val]
						end
					  end

					  table = Terminal::Table.new(:headings => ["Time", "Value"], :rows => rows )
					  puts(table) 
			  end

		end

	end

end
end

