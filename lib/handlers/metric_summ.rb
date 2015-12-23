module ITRP

class Cmd_metrics_summary   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'metricsum'
	end

	def enter(cmdline)

        patt = cmdline.scan(/metricsum\s+(.*)/).flatten

		p patt 

		use_key = patt.empty? ? appstate(:cgkey)  : patt[0]

		req =mk_request(TRP::Message::Command::METRICS_SUMMARY_REQUEST,
			{:metric_name=>patt[0] , :totals_only=>false, 
				 :time_interval =>  appstate( :time_interval) }) 


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

