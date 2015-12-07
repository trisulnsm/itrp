module ITRP

class Cmd_cglist  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = 'list'
		@trigger = 'counters'
	end


	def enter(cmdline)
		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST)

		rows = []
		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
			  	rows << [ group_detail.name,
						  group_detail.guid,
						  group_detail.bucket_size.to_i/1000
				        ]
			  end
		end

		table = Terminal::Table.new :headings => %w(name guid bs), :rows => rows
		puts(table) 
	end

end
end


