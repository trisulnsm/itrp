module ITRP

class Cmd_timeslices  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'timeslices'
	end

	def enter(cmdline)

		req =mk_request(TRP::Message::Command::TIMESLICES_REQUEST, 
				{ :get_disk_usage => true } )

        rows = [] 

		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
            resp.slices.each do | slice |
                rows << [ Time.at(slice.time_interval.from.tv_sec), 
						  Time.at(slice.time_interval.to.tv_sec) ,
						  slice.name , slice.status, slice.disk_size
				         ]
            end
        end 

		table = Terminal::Table.new( 
				:headings => %w(From  To Name Status DiskSz),
				:rows => rows)
		puts(table) 
    end

end
end

