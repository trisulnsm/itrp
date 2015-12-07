module ITRP

class Cmd_toppers  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'toppers'
	end

	def enter(cmdline)

		patt = cmdline.scan(/toppers ([0-9]+)/).flatten.first 

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::COUNTER_GROUP_REQUEST,
			 :counter_group => @appenv.context_data[:cgguid],
			 :meter => patt.to_i,
			 :resolve_keys => true,
			 :time_interval =>  mk_time_interval(@appenv.context_data[:time_window]))

		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  print "Counter Group = #{resp.counter_group}\n"
			  print "Meter = #{resp.meter}\n"

			  rows = [] 
			  resp.keys.each do |key|
			  		rows << [ key.key,
							  key.label,
							  key.readable,
							  key.metric ] 
			  end

			table = Terminal::Table.new :headings => ["Key", "Label", "Readable", "Metric"], :rows => rows
			puts(table) 
		end

	end

end
end

