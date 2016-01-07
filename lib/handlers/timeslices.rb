module ITRP

class Cmd_timeslices  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'timeslices'
	end

	def enter(cmdline)

		terms = cmdline.scan( /(\w+)\s*=\s*([\w\-_\.\:,\}\{]+)+/ )
		qparams = terms.inject({}) { |acc,t| acc.store( t[0].to_sym, t[1]);acc}


		p qparams 

		req =mk_request(TRP::Message::Command::TIMESLICES_REQUEST, 
				{ }.merge(qparams) )

        rows = [] 
        rows_window  = [] 

		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
            resp.slices.each do | slice |
                rows << [ Time.at(slice.time_interval.from.tv_sec), 
						  Time.at(slice.time_interval.to.tv_sec) ,
						  slice.name , slice.status, slice.disk_size
				         ]
            end

            if resp.total_window 
                rows_window << [  Time.at(resp.total_window.from.tv_sec), 
                                  Time.at(resp.total_window.to.tv_sec)]
            end
        end 



        p "Time Slices"
		table = Terminal::Table.new( 
				:headings => %w(From  To Name Status DiskSz),
				:rows => rows)
		puts(table) 

        p "Total Window"
		table = Terminal::Table.new( 
				:headings => %w(From  To ),
				:rows => rows_window)
		puts(table) 
    end

end
end

