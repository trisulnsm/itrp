module ITRP

class Cmd_metrics_summary   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'metricsum'
	end

	def enter(cmdline)

		terms = cmdline.scan( /(\w+)\s*=\s*([\w\-_\.\:,\}\{]+)+/ )
		qparams = terms.inject({}) { |acc,t| acc.store( t[0].to_sym, t[1]);acc}


		p qparams 

		req =mk_request(TRP::Message::Command::METRICS_SUMMARY_REQUEST,
			#{:time_interval =>  appstate( :time_interval) }.merge(qparams) ) 
			{}.merge(qparams) ) 


		rows = []
		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			resp.vals.each do |val|
				rows << [Time.at(val.ts.tv_sec) , val.val ]
			end
        end 

	   table = Terminal::Table.new(:headings => %w(Time Metric) ,  :rows => rows )
	   puts(table) 

    end

end
end

