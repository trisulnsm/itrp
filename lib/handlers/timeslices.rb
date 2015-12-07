module ITRP

class Cmd_timeslices  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'timeslices'
	end

	def enter(cmdline)

		req =mk_request(TRP::Message::Command::TIMESLICES_REQUEST,{:context=>0}) 	

        rows = [] 

		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
            resp.slices.each do | window |
                rows << [ Time.at(window.from.tv_sec), Time.at(window.to.tv_sec) ]
            end
        end 

		table = Terminal::Table.new( 
				:headings => %w(From  To),
				:rows => rows)
		puts(table) 
    end

end
end

