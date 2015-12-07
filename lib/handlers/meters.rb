module ITRP

class Cmd_meters < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'meters'
	end

	def enter(cmdline)
		req =mk_request(TRP::Message::Command::COUNTER_GROUP_INFO_REQUEST,
						 :counter_group => @appenv.context_data[:cgguid],
						 :get_meter_info => true )

		rows = []
		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			  resp.group_details.each do |group_detail|
			  	group_detail.meters.each do |meter|
					rows << [ meter.id, 
							  meter.name,
							  meter.description,
							  meter.type,
							  meter.topcount,
							  meter.units] 
				end
			  end
		end

		table = Terminal::Table.new( 
				:headings => %w(MeterNo Name Description Type TopperCount Units),
				:rows => rows)

		puts(table) 

	end
end

end

